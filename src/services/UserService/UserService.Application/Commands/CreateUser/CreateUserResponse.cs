namespace UserService.Application.Commands.CreateUser;

public record CreateUserResponse(Guid Id, string Name, string Email, DateTime CreatedAt);
