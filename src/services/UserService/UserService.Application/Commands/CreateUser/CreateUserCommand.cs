using MediatR;

namespace UserService.Application.Commands.CreateUser;

public record CreateUserCommand(string Name, string Email) : IRequest<CreateUserResponse>;
