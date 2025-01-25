using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Accidis.WebServices.Db;
using Accidis.WebServices.Exceptions;
using Accidis.WebServices.Models;
using Dapper;
using SkiaSharp;

namespace Accidis.WebServices.Services
{
	public sealed class AecPostImageRepository
	{
		const int ImageMaxWidthHeight = 2000;
		const int ResizedImageQuality = 80;

		public async Task<Guid> CreateAsync(Guid postId, byte[] imageBytes)
		{
			string mediaType;
			using(var stream = new MemoryStream(imageBytes))
			using(var codec = SKCodec.Create(stream, out var codecResult))
			{
				if(null == codec || SKCodecResult.Success != codecResult)
					throw new ImageException($"Failed to decode the image stream. The error is {codecResult}.");
				if(codec.Info.Width > ImageMaxWidthHeight || codec.Info.Height > ImageMaxWidthHeight)
					imageBytes = ResizeImage(imageBytes, codec, ImageMaxWidthHeight);
				mediaType = GetMediaTypeByCodec(codec.EncodedFormat);
			}

			using(var db = DbUtil.Open())
			{
				var imageId = await db.ExecuteScalarAsync<Guid>("insert into [PostImage] ([PostId], [Data], [MediaType]) output inserted.[Id] values (@PostId, @Data, @MediaType)",
					new { PostId = postId, Data = imageBytes, MediaType = mediaType });
				await db.ExecuteAsync("update [Post] set [Updated] = sysdatetime() where [Id] = @Id", new { Id = postId });
				return imageId;
			}
		}

		public async Task DeleteAsync(Guid imageId)
		{
			using(var db = DbUtil.Open())
			{
				await db.ExecuteAsync("delete from [PostImage] where [Id] = @Id", new { Id = imageId });
			}
		}

		public async Task<Guid[]> GetListByPostAsync(Guid postId)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<Guid>("select [Id] from [PostImage] where [PostId] = @PostId order by [Created]", new { PostId = postId });
				return result.ToArray();
			}
		}

		public async Task<PostImage> TryGetByIdAsync(Guid imageId)
		{
			using(var db = DbUtil.Open())
			{
				return await db.QueryFirstOrDefaultAsync<PostImage>("select * from [PostImage] where [Id] = @Id", new { Id = imageId });
			}
		}

		string GetMediaTypeByCodec(SKEncodedImageFormat format)
		{
			switch(format)
			{
				case SKEncodedImageFormat.Jpeg: return "image/jpeg";
				case SKEncodedImageFormat.Png: return "image/png";
				case SKEncodedImageFormat.Gif: return "image/gif";
				case SKEncodedImageFormat.Webp: return "image/webp";
				default: throw new ImageException($"Image format {format} is not supported.");
			}
		}

		byte[] ResizeImage(byte[] imageBytes, SKCodec codec, int maxWidthHeight)
		{
			try
			{
				var ratio = Math.Max((double)codec.Info.Width / maxWidthHeight, (double)codec.Info.Height / maxWidthHeight);
				var destWidth = (int)(codec.Info.Width / ratio);
				var destHeight = (int)(codec.Info.Height / ratio);

				using(var stream = new MemoryStream(imageBytes))
				using(var source = SKBitmap.Decode(stream))
				using(var dest = new SKBitmap(destWidth, destHeight, SKImageInfo.PlatformColorType, SKAlphaType.Premul))
				{
					source.ScalePixels(dest, new SKSamplingOptions(SKCubicResampler.Mitchell));
					using(var destData = dest.Encode(codec.EncodedFormat, ResizedImageQuality))
					{
						return destData.ToArray();
					}
				}
			}
			catch(Exception ex)
			{
				throw new ImageException("Image is too large and automatic resizing failed.", ex);
			}
		}
	}
}