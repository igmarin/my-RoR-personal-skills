
## Supported LLM Providers

- **OpenAI** – default configuration uses `gpt-4o`.
- **Gemini** – default configuration uses `gemini-1.5-flash-latest`.
- **Ollama** – newly added provider for open‑source models (e.g., Qwen 3.5). Configure via:
  ```yaml
  llm_providers_config:
    ollama:
      api_key: null # usually not required
      model: qwen:7b
      base_url: http://localhost:11434
  ```

## Adding New Providers

To add another open‑source provider:
1. Create a class under `evaluator/lib/clients/providers/` extending `BaseClient`.
2. Implement `base_url`, `request_path`, and `config_error`.
3. Add a default entry in `defaults.rb`.
4. Register the provider in `client.rb`’s `provider_client_class` case statement.
5. Add tests and update documentation.
