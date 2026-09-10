import logging
from pathlib import Path
from datetime import datetime

def get_logger(name: str = "etl"):
    Path("logs").mkdir(exist_ok=True)
    log_file = Path("logs") / f"etl_{datetime.now():%Y-%m-%d}.log"

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=[
            logging.FileHandler(log_file, encoding="utf-8"),
            logging.StreamHandler()
        ],
    )
    return logging.getLogger(name)
