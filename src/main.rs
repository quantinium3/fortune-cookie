use axum::{Router, response::Json, routing::get};
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};

#[derive(Serialize)]
struct Message {
    message: String,
}

#[derive(Deserialize)]
struct Fortune {
    fortune: String,
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/", get(get_fortune));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    println!("Server running at: http://localhost:3000");
    axum::serve(listener, app).await.unwrap();
}

async fn get_fortune() -> Result<Json<Message>, StatusCode> {
    let body = reqwest::get("http://yerkee.com/api/fortune")
        .await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?
        .json::<Fortune>()
        .await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    Ok(Json(Message {
        message: body.fortune,
    }))
}
