import azure.functions as func
import requests

GCP_LB_URL = "http://34.0.66.75" 

def forward_request(req: func.HttpRequest) -> func.HttpResponse:
    try:
        headers = {key: value for key, value in req.headers.items() if key.lower() != "host"}
        response = requests.post(GCP_LB_URL, headers=headers, data=req.get_body())

        return func.HttpResponse(response.text, status_code=response.status_code)

    except Exception as e:
        return func.HttpResponse(str(e), status_code=500)

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="windows-function-app1", methods=["POST"])
def main(req: func.HttpRequest) -> func.HttpResponse:
    return forward_request(req)
