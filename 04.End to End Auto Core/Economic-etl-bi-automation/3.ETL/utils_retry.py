import time
import random

def retry_call(
    func,
    tries=5,
    base_sleep=1.0,
    max_sleep=8.0,
    logger=None,
    step_name="step",
    retry_on=(Exception,),
):
    last_error = None

    for attempt in range(1, tries + 1):
        try:
            return func()

        except retry_on as e:
            last_error = e

            if attempt == tries:
                break

            sleep_time = min(max_sleep, base_sleep * (2 ** (attempt - 1)))
            sleep_time += random.uniform(0, 0.5)

            if logger:
                logger.warning(
                    f"{step_name} failed. retry {attempt}/{tries}, sleep={sleep_time:.1f}s, error={e}"
                )

            time.sleep(sleep_time)

    raise last_error