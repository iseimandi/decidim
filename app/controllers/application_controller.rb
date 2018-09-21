class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  rescue_from ::ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ::ActionController::UnknownFormat, with: :render_404

  def render_404
    render(
      file: "public/404",
      status: 404,
      layout: "layouts/decidim/application",
      handlers: [:erb],
      formats: [:html]
    ) and return
  end

end
