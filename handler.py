import json
import random


def _parse_names(event):
    """
    イベントから名前リストを抽出する
    クエリパラメータまたはリクエストボディから取得
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
    Lambda レスポンスを生成する
    """
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json; charset=utf-8",
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps(obj, ensure_ascii=False),
    }


def lambda_handler(event, context):
    """
    Lambda のメインハンドラー
    ランダムに1つの候補を選択して返す
    """
    names = _parse_names(event)
    if not names:
        return _resp(400, {
            "error": "BadRequest",
            "message": "list パラメータに候補を指定してください。例: ?list=山田,大田,伊藤"
        })

    winner = random.choice(names)
    return _resp(200, {
        "winner": winner,
        "candidates": names,
        "count": len(names)
    })

