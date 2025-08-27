using FluentAssertions;
using UserService.Domain.Entities;

namespace UserService.Tests.Unit.Domain.Entities;

public class UserTests
{
    [Fact]
    public void Constructor_WithValidParameters_ShouldCreateUser()
    {
        // Arrange
        var name = "John Doe";
        var email = "john.doe@email.com";

        // Act
        var user = new User(name, email);

        // Assert
        user.Name.Should().Be(name);
        user.Email.Should().Be(email);
        user.Id.Should().NotBeEmpty();
        user.CreatedAt.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(1));
        user.UpdatedAt.Should().BeNull();
    }

    [Fact]
    public void Constructor_WithNullName_ShouldThrowArgumentNullException()
    {
        // Arrange
        string name = null!;
        var email = "john.doe@email.com";

        // Act & Assert
        var act = () => new User(name, email);
        act.Should().Throw<ArgumentNullException>().WithParameterName("name");
    }

    [Fact]
    public void UpdateName_WithValidName_ShouldUpdateNameAndSetUpdatedAt()
    {
        // Arrange
        var user = new User("John Doe", "john.doe@email.com");
        var newName = "Jane Doe";

        // Act
        user.UpdateName(newName);

        // Assert
        user.Name.Should().Be(newName);
        user.UpdatedAt.Should().NotBeNull();
        user.UpdatedAt.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(1));
    }

    [Fact]
    public void UpdateEmail_WithValidEmail_ShouldUpdateEmailAndSetUpdatedAt()
    {
        // Arrange
        var user = new User("John Doe", "john.doe@email.com");
        var newEmail = "jane.doe@email.com";

        // Act
        user.UpdateEmail(newEmail);

        // Assert
        user.Email.Should().Be(newEmail);
        user.UpdatedAt.Should().NotBeNull();
        user.UpdatedAt.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(1));
    }
}
