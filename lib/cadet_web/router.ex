defmodule CadetWeb.Router do
  use CadetWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(:put_secure_browser_headers)
  end

  pipeline :auth do
    plug(Cadet.Auth.Pipeline)
    plug(CadetWeb.Plug.AssignCurrentUser)
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  # Public Pages
  scope "/v1", CadetWeb do
    pipe_through([:api, :auth])

    post("/auth", AuthController, :create)
    post("/auth/refresh", AuthController, :refresh)
    post("/auth/logout", AuthController, :logout)
  end

  # Authenticated Pages
  scope "/v1", CadetWeb do
    pipe_through([:api, :auth, :ensure_auth])

    resources("/assessments", AssessmentsController, only: [:index, :show])
    post("/assessments/:assessmentid/submit", AssessmentsController, :submit)
    post("/assessments/question/:questionid/submit", AnswerController, :submit)

    get("/grading", GradingController, :index)
    get("/grading/:submissionid", GradingController, :show)
    post("/grading/:submissionid/:questionid", GradingController, :update)

    get("/user", UserController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", CadetWeb do
  #   pipe_through :api
  # end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "cadet"
      },
      basePath: "/v1",
      securityDefinitions: %{
        JWT: %{
          type: "apiKey",
          in: "header",
          name: "Authorization"
        }
      }
    }
  end

  scope "/swagger" do
    forward("/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :cadet, swagger_file: "swagger.json")
  end
end
