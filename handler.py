import json
import random
import os
from string import Template


def _parse_names(event):
    """
    Extract names list from event
    Get from query parameters or request body
    """
    params = event.get("queryStringParameters") or {}
    list_param = params.get("list")

    body = event.get("body")
    if not list_param and body:
        try:
            data = json.loads(body)
            if isinstance(data.get("list"), list):
                return [str(x).strip() for x in data["list"] if str(x).strip()]
            if isinstance(data.get("list"), str):
                list_param = data["list"]
        except Exception:
            pass

    if list_param:
        raw = (
            str(list_param)
            .replace("，", ",")
            .replace("\n", ",")
            .split(",")
        )
        return [s.strip() for s in raw if s.strip()]
    return []


def _resp(status, obj):
    """
    Generate Lambda response (JSON format)
    """
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json; charset=utf-8",
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps(obj, ensure_ascii=False),
    }


def _resp_html(status, winner):
    """
    Generate Lambda response (HTML format)
    """
    template_path = os.path.join(os.path.dirname(__file__), "templates", "winner.html")
    with open(template_path, "r", encoding="utf-8") as f:
        template = Template(f.read())
    
    html_content = template.substitute(winner=winner)
    
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "text/html; charset=utf-8",
            "Access-Control-Allow-Origin": "*",
        },
        "body": html_content,
    }


def lambda_handler(event, context):
    """
    Lambda's main handler (entrypoint)
    """

    names = _parse_names(event)
    if not names:
        return _resp(400, {
            "error": "BadRequest",
            "message": "Please specify candidates in the list parameter. Example: ?list=Alice,Bob,Carol"
        })

    winner = random.choice(names)
    return _resp_html(200, winner)

