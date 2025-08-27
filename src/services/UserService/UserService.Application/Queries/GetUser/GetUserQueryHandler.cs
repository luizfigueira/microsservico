using MediatR;
using UserService.Domain.Repositories;

namespace UserService.Application.Queries.GetUser;

public class GetUserQueryHandler : IRequestHandler<GetUserQuery, GetUserResponse?>
{
    private readonly IUserRepository _userRepository;

    public GetUserQueryHandler(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public async Task<GetUserResponse?> Handle(GetUserQuery request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.Id, cancellationToken);
        
        if (user == null)
            return null;

        return new GetUserResponse(user.Id, user.Name, user.Email, user.CreatedAt, user.UpdatedAt);
    }
}
