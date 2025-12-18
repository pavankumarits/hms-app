from typing import List, Dict, Any

# Simple in-memory queue. In production, use Redis.
SYNC_QUEUE: List[Dict[str, Any]] = []

def add_to_queue(payload: Any):
    SYNC_QUEUE.append(payload)

def get_queue():
    return SYNC_QUEUE

def clear_queue():
    SYNC_QUEUE.clear()
