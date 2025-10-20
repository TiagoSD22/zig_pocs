# Zig REST API with Zap

A simple REST API built with Zig using the Zap web framework that responds with "Hello {name}" messages.

## Features

- GET endpoint: `/hello?name=YourName`
- POST endpoint: `/hello` with JSON body `{"name": "YourName"}`
- Health check endpoint: `/health`
- Unit tests included
- Docker support

## Requirements

- Zig 0.16.0-dev
- Docker (for containerized deployment)

## Local Development

### Building and Running

```bash
# Build the project
zig build

# Run the application
zig build run

# Run tests
zig build test
```

The server will start on port 8080.

### API Usage

#### GET Request
```bash
curl "http://localhost:8080/hello?name=World"
# Response: Hello World

curl "http://localhost:8080/hello?name=Zig"
# Response: Hello Zig
```

#### POST Request
```bash
curl -X POST "http://localhost:8080/hello" \
  -H "Content-Type: application/json" \
  -d '{"name": "ZigLang"}'
# Response: Hello ZigLang
```

#### Health Check
```bash
curl "http://localhost:8080/health"
# Response: {"status":"ok"}
```

## Docker Deployment

### Build Docker Image
```bash
docker build -t zig-rest-api .
```

### Run Docker Container
```bash
docker run -p 8080:8080 zig-rest-api
```

### Test the Dockerized API
```bash
curl "http://localhost:8080/hello?name=Docker"
# Response: Hello Docker
```

## Project Structure

```
├── build.zig          # Build configuration
├── build.zig.zon      # Package configuration
├── Dockerfile         # Docker configuration
├── src/
│   ├── main.zig       # Main application
│   └── test.zig       # Unit tests
└── README.md          # This file
```

## API Endpoints

| Method | Endpoint | Description | Parameters |
|--------|----------|-------------|------------|
| GET    | `/hello` | Returns greeting with query parameter | `name` (query param) |
| POST   | `/hello` | Returns greeting with JSON body | `{"name": "string"}` |
| GET    | `/health` | Health check endpoint | None |

## Testing

The project includes unit tests for:
- Basic hello message formatting
- JSON parsing logic
- Response formatting with various inputs
- Edge cases and error handling

Run tests with:
```bash
zig build test
```

## Notes

- If no name is provided, defaults to "World"
- Invalid JSON in POST requests returns 400 Bad Request
- Server runs with 2 threads and 2 workers for better performance
- Uses Zap framework version 0.8.0