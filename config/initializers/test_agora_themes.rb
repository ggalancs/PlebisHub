# Test environment configuration for Agora
if Rails.env.test?
  # Ensure agora configuration is properly initialized for tests
  Rails.application.config.after_initialize do
    agora = Rails.application.secrets.agora ||= {}

    # Ensure themes are set
    agora["themes"] ||= ["default", "mytheme"]

    # Ensure servers are configured
    agora["servers"] ||= {
      "default" => {
        "shared_key" => "test_shared_key_for_testing",
        "url" => "https://test.example.com/"
      },
      "agora" => {
        "shared_key" => "test_shared_key_for_testing",
        "url" => "https://test.example.com/"
      }
    }

    # Ensure default server is set
    agora["default"] ||= "agora"
  end
end
