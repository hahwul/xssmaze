# XSSMaze Development Instructions

XSSMaze is a Crystal-based web application designed to be vulnerable to XSS (Cross-Site Scripting) attacks. It serves as a testing platform to measure and enhance the performance of security testing tools. The application uses the Kemal web framework and provides various XSS vulnerability scenarios.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Prerequisites and Setup
- Install Crystal programming language (version 1.8.2 as specified in shard.yml)
- Ensure network connectivity for dependency installation
- Docker (optional, for containerized builds)

### Bootstrap, Build, and Test the Repository
```bash
# Install Crystal dependencies
shards install
# NEVER CANCEL: Dependency installation can take 5-10 minutes depending on network speed. Set timeout to 15+ minutes.

# Development build
shards build
# NEVER CANCEL: Build takes 2-5 minutes depending on system. Set timeout to 10+ minutes.

# Production build (recommended for deployment)
shards build --release --no-debug --production
# NEVER CANCEL: Production build takes 3-7 minutes with optimizations. Set timeout to 15+ minutes.

# Run tests
crystal spec
# NEVER CANCEL: Test suite takes 1-2 minutes. Set timeout to 5+ minutes.
```

### Running the Application
```bash
# Run XSSMaze (after successful build)
./bin/xssmaze

# Alternative: Run with custom configuration
./bin/xssmaze -b 127.0.0.1 -p 8080

# Default runs on http://0.0.0.0:3000
```

### Command Line Options
- `-b HOST, --bind HOST`: Host to bind (defaults to 0.0.0.0)
- `-p PORT, --port PORT`: Port to listen for connections (defaults to 3000)
- `-s, --ssl`: Enables SSL
- `--ssl-key-file FILE`: SSL key file
- `--ssl-cert-file FILE`: SSL certificate file
- `-h, --help`: Shows help

### Docker Build and Run
```bash
# Build Docker image
docker build -t xssmaze .
# NEVER CANCEL: Docker build takes 10-15 minutes. Set timeout to 30+ minutes.

# Run using pre-built image
docker run -p 3000:3000 ghcr.io/hahwul/xssmaze:main

# Build and run for ARM
docker build -f Dockerfile.arm -t xssmaze-arm .
```

## Validation

### Manual Testing Scenarios
After building and running XSSMaze, ALWAYS validate functionality by:

1. **Basic Connectivity Test:**
   ```bash
   curl http://localhost:3000/
   # Should return HTML with XSSMaze title and endpoint list
   ```

2. **API Endpoint Tests:**
   ```bash
   # Test map endpoints
   curl http://localhost:3000/map/text
   curl http://localhost:3000/map/json
   # Should return list of vulnerable endpoints
   ```

3. **XSS Vulnerability Tests:**
   ```bash
   # Test basic XSS endpoint
   curl "http://localhost:3000/basic/level1/?query=<script>alert(1)</script>"
   # Should return the script tag (demonstrates vulnerability)

   # Test escaped XSS endpoint
   curl "http://localhost:3000/basic/level2/?query=<script>alert(1)</script>"
   # Should return escaped content
   ```

4. **Complete User Scenario:**
   - Access the main page at http://localhost:3000
   - Verify all XSS test cases are listed
   - Test at least 3 different vulnerability levels
   - Check that /map/json returns valid JSON with endpoint list

### Linting and Code Quality
```bash
# Install Crystal Ameba linter (if not installed)
# The CI uses crystal-ameba/github-action@v0.8.0

# Run linting (via GitHub Actions workflow)
# Manual linting requires Ameba to be installed separately
```

## Repository Structure and Navigation

### Key Directories
```
/home/runner/work/xssmaze/xssmaze/
├── src/                    # Main source code
│   ├── xssmaze.cr         # Application entry point
│   ├── maze.cr            # Maze class definition
│   ├── banner.cr          # Application banner
│   └── mazes/             # XSS vulnerability implementations
│       ├── basic.cr       # Basic XSS scenarios
│       ├── dom.cr         # DOM-based XSS
│       ├── header.cr      # Header injection XSS
│       ├── post.cr        # POST-based XSS
│       └── [others].cr    # Additional XSS types
├── spec/                  # Test files
│   ├── spec_helper.cr     # Test configuration
│   └── xssmaze_spec.cr    # Main test suite (minimal)
├── .github/workflows/     # CI/CD configuration
├── shard.yml             # Dependencies (like package.json)
├── shard.lock           # Lock file with exact versions
├── Dockerfile           # Docker build configuration
└── README.md           # Project documentation
```

### Important Files to Review When Making Changes
- Always check `src/xssmaze.cr` after modifying route definitions
- Review `shard.yml` when adding new dependencies
- Update `README.md` if adding new XSS vulnerability types
- Check existing maze files in `src/mazes/` for patterns when adding new vulnerabilities

### XSS Maze Categories
The application includes these vulnerability categories:
- **Basic XSS** (`basic.cr`): 7 levels of basic reflection vulnerabilities
- **DOM XSS** (`dom.cr`): Client-side DOM manipulation vulnerabilities
- **Header Injection** (`header.cr`): HTTP header-based XSS
- **Path-based** (`path.cr`): URL path injection vulnerabilities
- **POST-based** (`post.cr`): Form submission XSS
- **Redirect** (`redirect.cr`): URL redirection vulnerabilities
- **Decode** (`decode.cr`): Encoding/decoding bypass scenarios
- **Hidden XSS** (`hidden_xss.cr`): Non-obvious XSS cases
- **Injection XSS** (`injs_xss.cr`): SQL injection combined with XSS
- **In-Frame XSS** (`inframe_xss.cr`): Frame-based XSS
- **In-Attribute XSS** (`inattr_xss.cr`): HTML attribute injection
- **JavaScript Function XSS** (`jf_xss.cr`): Function call vulnerabilities
- **Event Handler XSS** (`event_handler.cr`): HTML event handler injection

## Common Tasks and Troubleshooting

### Dependency Issues
- If `shards install` fails due to network issues, check internet connectivity
- Dependency resolution can fail if GitHub is inaccessible
- The application requires the Kemal framework (version 1.7.2)

### Build Failures
- Ensure Crystal version matches shard.yml specification (1.8.2)
- Build failures often relate to syntax errors in .cr files
- Production builds are more strict than development builds

### Runtime Issues
- Application runs on port 3000 by default
- Check if port is available: `lsof -i :3000`
- Application requires no external database or services

### CI/CD Information
- GitHub Actions run Crystal builds and linting automatically
- Build workflow uses `crystallang/crystal` Docker image
- Lint workflow uses `crystal-ameba/github-action@v0.8.0`
- Docker images are published to `ghcr.io/hahwul/xssmaze:main`

## Timing Expectations and Timeouts

Based on successful GitHub Actions builds, here are realistic timing expectations:

| Operation | Expected Time | Timeout Recommendation | Notes |
|-----------|---------------|------------------------|-------|
| `shards install` | 1-30 seconds | 5+ minutes | Network dependent |
| `shards build` | 15-30 seconds | 5+ minutes | Development build |
| `shards build --release` | 30-90 seconds | 5+ minutes | Production optimized |
| `crystal spec` | 5-15 seconds | 2+ minutes | Minimal test suite |
| Docker build | 5-15 minutes | 30+ minutes | Multi-stage build with downloads |
| Application startup | 1-3 seconds | 30 seconds | Port binding time |

**CRITICAL**: NEVER CANCEL any build or test commands. Crystal compilation can be slow, especially for release builds with optimizations.

**Note**: Times above are based on CI environment performance. Local builds may vary significantly based on system specs and network connectivity.

## Network Dependencies

The application requires internet access for:
- Installing dependencies via `shards install`
- Fetching Kemal framework and related libraries from GitHub
- Docker base image downloads

If network access is restricted:
- Build may fail with "Could not resolve host" errors
- Use pre-built Docker images when available: `docker pull ghcr.io/hahwul/xssmaze:main`
- Consider offline Crystal installation methods

### Network Troubleshooting
- Docker build failures with "fatal: unable to access" indicate network connectivity issues
- Pre-built images may have compatibility issues in some environments
- If Docker image fails with library errors, the environment may lack required system libraries (libpcre2, libgc, etc.)

## Development Patterns

### Adding New XSS Scenarios
When adding new vulnerability scenarios, follow these patterns:

1. **Create route in maze file:**
   ```crystal
   Xssmaze.push("scenario-name", "/path/to/endpoint?query=a", "description")
   get "/path/to/endpoint" do |env|
     # XSS vulnerability implementation
     env.params.query["query"] # or manipulated version
   end
   ```

2. **Load maze in main file:**
   Add `load_your_maze` call in `src/xssmaze.cr`

3. **Test the endpoint:**
   ```bash
   curl "http://localhost:3000/your/endpoint?query=<script>alert(1)</script>"
   ```

### Crystal Language Patterns
- Use `env.params.query["parameter"]` to access GET parameters
- Use `env.params.body["parameter"]` for POST parameters  
- String manipulation: `.gsub("old", "new")` for replacements
- HTML escaping methods available through Kemal framework