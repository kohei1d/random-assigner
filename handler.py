import json
import random


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
    html_content = f"""<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Winning Result</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Hiragino Sans", "Hiragino Kaku Gothic ProN", Meiryo, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #3fc1b0 0%, #2a9d8f 100%);
        }}
        .container {{
            background: white;
            padding: 3rem 4rem;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            text-align: center;
            max-width: 600px;
            width: 90%;
        }}
        .winner {{
            font-size: 3rem;
            font-weight: bold;
            color: #3fc1b0;
            margin-bottom: 1rem;
            animation: fadeInScale 0.6s ease-out;
        }}
        .message {{
            font-size: 1.5rem;
            color: #333;
            line-height: 1.8;
        }}
        @keyframes fadeInScale {{
            from {{
                opacity: 0;
                transform: scale(0.8);
            }}
            to {{
                opacity: 1;
                transform: scale(1);
            }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="winner">{winner}</div>
        <div class="message">Congrats!</div>
    </div>
</body>
</html>"""
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

