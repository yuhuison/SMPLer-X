from pymongo import MongoClient

client = MongoClient('mongodb://154.92.16.121:27017/')
db = client['meocap-vision']
tasks = db["tasks"]


def fetch_wait_task():
    pass


def update_task_status(video_task_sha, status):
    pass


def update_result(video_task_sha, result):
    pass


def append_task(video_task_sha):
    pass


def get_task_wait_count_and_time():
    pass


def get_quene_status():
    pass
