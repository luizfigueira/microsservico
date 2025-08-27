using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FluentAssertions;
using UserService.Application.Commands.CreateUser;
using UserService.Application.Queries.GetUser;
using UserService.Tests.Integration.Infrastructure;

namespace UserService.Tests.Integration.Controllers;

[Collection("Integration")]
public class UsersControllerTests : IClassFixture<IntegrationTestWebAppFactory>
{
    private readonly HttpClient _client;
    private readonly IntegrationTestWebAppFactory _factory;

    public UsersControllerTests(IntegrationTestWebAppFactory factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task CreateUser_WithValidRequest_ShouldReturnCreatedUser()
    {
        // Arrange
        var command = new CreateUserCommand("John Doe", "john.doe@email.com");

        // Act
        var response = await _client.PostAsJsonAsync("/api/users", command);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        
        var content = await response.Content.ReadAsStringAsync();
        var result = JsonSerializer.Deserialize<CreateUserResponse>(content, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        result.Should().NotBeNull();
        result!.Name.Should().Be(command.Name);
        result.Email.Should().Be(command.Email);
        result.Id.Should().NotBeEmpty();
    }

    [Fact]
    public async Task CreateUser_WithDuplicateEmail_ShouldReturnBadRequest()
    {
        // Arrange
        var command = new CreateUserCommand("John Doe", "duplicate@email.com");

        // Create first user
        await _client.PostAsJsonAsync("/api/users", command);

        // Act - try to create user with same email
        var response = await _client.PostAsJsonAsync("/api/users", command);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task GetUser_WithExistingId_ShouldReturnUser()
    {
        // Arrange
        var createCommand = new CreateUserCommand("Jane Doe", "jane.doe@email.com");
        var createResponse = await _client.PostAsJsonAsync("/api/users", createCommand);
        var createContent = await createResponse.Content.ReadAsStringAsync();
        var createdUser = JsonSerializer.Deserialize<CreateUserResponse>(createContent, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        // Act
        var response = await _client.GetAsync($"/api/users/{createdUser!.Id}");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        
        var content = await response.Content.ReadAsStringAsync();
        var result = JsonSerializer.Deserialize<GetUserResponse>(content, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        result.Should().NotBeNull();
        result!.Id.Should().Be(createdUser.Id);
        result.Name.Should().Be(createdUser.Name);
        result.Email.Should().Be(createdUser.Email);
    }

    [Fact]
    public async Task GetUser_WithNonExistingId_ShouldReturnNotFound()
    {
        // Arrange
        var nonExistingId = Guid.NewGuid();

        // Act
        var response = await _client.GetAsync($"/api/users/{nonExistingId}");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }
}
