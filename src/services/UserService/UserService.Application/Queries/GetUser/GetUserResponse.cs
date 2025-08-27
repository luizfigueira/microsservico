namespace UserService.Application.Queries.GetUser;

public record GetUserResponse(Guid Id, string Name, string Email, DateTime CreatedAt, DateTime? UpdatedAt);
