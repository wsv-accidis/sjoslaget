using System;
using System.Linq;
using System.Threading.Tasks;
using Accidis.WebServices.Db;
using Accidis.WebServices.Models;
using Dapper;
using Markdig;

namespace Accidis.WebServices.Services
{
	public sealed class AecPostRepository
	{
		readonly MarkdownPipeline _markdown;

		public AecPostRepository()
		{
			_markdown = new MarkdownPipelineBuilder().UseAutoLinks().DisableHtml().Build();
		}

		public async Task<Guid> CreateAsync(PostSource post)
		{
			using(var db = DbUtil.Open())
			{
				var contentHtml = Markdown.ToHtml(post.Content, _markdown);

				return await db.ExecuteScalarAsync<Guid>("insert into [Post] ([Content], [ContentHtml]) output inserted.[Id] values (@Content, @ContentHtml)",
					new { post.Content, ContentHtml = contentHtml });
			}
		}

		public async Task DeleteAsync(Post post)
		{
			using(var db = DbUtil.Open())
			{
				await db.ExecuteAsync("delete from [Post] where [Id] = @Id", new { post.Id });
			}
		}

		public async Task UpdateAsync(PostSource post)
		{
			using(var db = DbUtil.Open())
			{
				var contentHtml = Markdown.ToHtml(post.Content, _markdown);

				await db.ExecuteAsync("update [Post] set [Content] = @Content, [ContentHtml] = @ContentHtml, [Updated] = sysdatetime() where [Id] = @Id",
					new { post.Id, post.Content, ContentHtml = contentHtml });
			}
		}

		public async Task<Post> GetByIdAsync(Guid id)
		{
			using(var db = DbUtil.Open())
			{
				return await db.QueryFirstOrDefaultAsync<Post>("select * from [Post] where [Id] = @Id", new { Id = id });
			}
		}

		public async Task<PostListItem[]> GetListAsync()
		{
			using(var db = DbUtil.Open())
			{
				var list = await db.QueryAsync<PostListItem>("select [Id], LEFT([Content], 64) [ContentPreview], [Created], [Updated] from [Post] order by [Created] desc");
				return list.ToArray();
			}
		}

		public async Task<Post[]> GetWindowByIndexAsync(int offset, int limit)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<Post>("select * from [Post] order by [Created] desc offset @Offset rows fetch next @Limit rows only",
					new { Offset = offset, Limit = limit });
				return result.ToArray();
			}
		}

		public async Task<DateTime?> GetLastUpdatedByIndexAsync(int offset, int limit)
		{
			using(var db = DbUtil.Open())
			{
				return await db.ExecuteScalarAsync<DateTime?>("select MAX([Updated]) from (select [Updated] from [db-73w].[dbu-73w].[Post] order by [Created] desc offset @Offset rows fetch next @Limit rows only) A",
					new { Offset = offset, Limit = limit });
			}
		}
	}
}