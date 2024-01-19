using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Exceptions;
using Accidis.WebServices.Models;
using Accidis.WebServices.Services;
using Accidis.WebServices.Web;
using NLog;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class PostsController : ApiController
	{
		readonly AecPostImageRepository _imageRepository;
		readonly Logger _log = LogManager.GetLogger(nameof(BookingsController));
		readonly AecPostRepository _postRepository;

		public PostsController(AecPostImageRepository imageRepository, AecPostRepository postRepository)
		{
			_imageRepository = imageRepository;
			_postRepository = postRepository;
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		[Route("api/posts")]
		public async Task<IHttpActionResult> CreateUpdate(PostSource postSource)
		{
			try
			{
				var existingPost = !Guid.Empty.Equals(postSource.Id)
					? await _postRepository.GetByIdAsync(postSource.Id)
					: null;

				if(null != existingPost)
				{
					existingPost.Content = postSource.Content;
					await _postRepository.UpdateAsync(postSource);
				}
				else
				{
					postSource.Id = await _postRepository.CreateAsync(postSource);
				}

				return Ok(new PostResult(postSource.Id));
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while creating/updating the post.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpDelete]
		[Route("api/posts/{postId}")]
		public async Task<IHttpActionResult> Delete(Guid postId)
		{
			try
			{
				var post = await _postRepository.GetByIdAsync(postId);
				if(null == post)
					return NotFound();

				await _postRepository.DeleteAsync(post);
				return Ok();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while deleting the post.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpDelete]
		[Route("api/images/{imageId}")]
		public async Task<IHttpActionResult> DeleteImage(Guid imageId)
		{
			try
			{
				// Does not actually check if the image exists, but this is fine.
				await _imageRepository.DeleteAsync(imageId);
				return Ok();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while deleting an image.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		[Route("api/posts/{postId}")]
		public async Task<IHttpActionResult> Get(Guid postId)
		{
			try
			{
				var post = await _postRepository.GetByIdAsync(postId);
				if(null == post)
					return NotFound();

				post.Images = await _imageRepository.GetListByPostAsync(postId);
				return this.OkNoCache(post);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting the post.");
				throw;
			}
		}

		[HttpGet]
		[Route("api/posts/window/{offset}/{limit}")]
		public async Task<IHttpActionResult> GetWindow(int offset, int limit)
		{
			try
			{
				var lastModified = await _postRepository.GetLastUpdatedByIndexAsync(offset, limit);
				if(!lastModified.HasValue) // If window is empty, shortcut to empty list
					return this.OkNoCache(Array.Empty<Post>());

				var etag = $"\"{lastModified.Value.ToBinary()}\"";
				if(Request.Headers.IfNoneMatch.Contains(new EntityTagHeaderValue(etag)))
					return StatusCode(HttpStatusCode.NotModified);

				var posts = await _postRepository.GetWindowByIndexAsync(offset, limit);
				foreach(var p in posts)
					p.Images = await _imageRepository.GetListByPostAsync(p.Id);

				return this.OkEtag(posts, etag);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting posts.");
				throw;
			}
		}

		[HttpGet]
		[Route("api/images/{imageId}")]
		public async Task<IHttpActionResult> GetImage(Guid imageId)
		{
			try
			{
				var image = await _imageRepository.TryGetByIdAsync(imageId);
				if(null == image || !image.HasData)
					return NotFound();

				var content = new ByteArrayContent(image.Data);
				content.Headers.ContentType = new MediaTypeHeaderValue(image.MediaType);
				var result = new HttpResponseMessage(HttpStatusCode.OK) { Content = content };
				result.Headers.CacheControl = new CacheControlHeaderValue { MaxAge = TimeSpan.FromDays(90) };
				return ResponseMessage(result);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting an image.");
				throw;
			}
		}


		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		[Route("api/posts")]
		public async Task<IHttpActionResult> List()
		{
			try
			{
				var listItems = await _postRepository.GetListAsync();
				return this.OkNoCache(listItems);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting a list of posts.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		[Route("api/images")]
		public async Task<IHttpActionResult> UploadImage(PostImageSource source)
		{
			try
			{
				if(null == source)
					throw new ArgumentNullException("source");
				if(string.IsNullOrEmpty(source.ImageBytes))
					throw new ArgumentNullException("source.ImageBytes");

				var imageBytes = Convert.FromBase64String(source.ImageBytes);
				var id = await _imageRepository.CreateAsync(source.PostId, imageBytes);
				return Ok(new PostResult(id));
			}
			catch(ArgumentException ex)
			{
				_log.Error(ex, "Invalid data was provided while uploading an image.");
				return BadRequest(ex.Message);
			}
			catch(ImageException ex)
			{
				_log.Error(ex, "An image validation error occurred while uploading an image.");
				return BadRequest(ex.Message);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while uploading an image.");
				throw;
			}
		}
	}
}