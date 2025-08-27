using MediatR;

namespace UserService.Application.Queries.GetUser;

public record GetUserQuery(Guid Id) : IRequest<GetUserResponse?>;
