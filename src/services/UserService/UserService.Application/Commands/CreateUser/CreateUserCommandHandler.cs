using MediatR;
using UserService.Domain.Entities;
using UserService.Domain.Repositories;

namespace UserService.Application.Commands.CreateUser;

public class CreateUserCommandHandler : IRequestHandler<CreateUserCommand, CreateUserResponse>
{
    private readonly IUserRepository _userRepository;

    public CreateUserCommandHandler(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public async Task<CreateUserResponse> Handle(CreateUserCommand request, CancellationToken cancellationToken)
    {
        // Check if user with email already exists
        var existingUser = await _userRepository.GetByEmailAsync(request.Email, cancellationToken);
        if (existingUser != null)
        {
            throw new InvalidOperationException($"User with email {request.Email} already exists");
        }

        var user = new User(request.Name, request.Email);
        await _userRepository.AddAsync(user, cancellationToken);

        return new CreateUserResponse(user.Id, user.Name, user.Email, user.CreatedAt);
    }
}
