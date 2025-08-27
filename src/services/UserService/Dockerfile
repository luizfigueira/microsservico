FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["src/services/UserService/UserService.API/UserService.API.csproj", "src/services/UserService/UserService.API/"]
COPY ["src/services/UserService/UserService.Application/UserService.Application.csproj", "src/services/UserService/UserService.Application/"]
COPY ["src/services/UserService/UserService.Domain/UserService.Domain.csproj", "src/services/UserService/UserService.Domain/"]
COPY ["src/services/UserService/UserService.Infrastructure/UserService.Infrastructure.csproj", "src/services/UserService/UserService.Infrastructure/"]
RUN dotnet restore "src/services/UserService/UserService.API/UserService.API.csproj"
COPY . .
WORKDIR "/src/src/services/UserService/UserService.API"
RUN dotnet build "UserService.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "UserService.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "UserService.API.dll"]
