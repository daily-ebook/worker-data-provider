from celery import Celery
import mongoengine

# for tasks
import ded

celery = Celery('tasks',
            broker="redis://redis:6379/0",
            backend="redis://redis:6379/0")
# mongoengine.connect('celery_beat_daily_epub') useless for now 
confs = {
    "CELERY_MONGODB_SCHEDULER_DB": "celery_beat_daily_epub",
    "CELERY_MONGODB_SCHEDULER_COLLECTION" : "schedules", # we can't really change this, there is no current_app according to
    "CELERY_MONGODB_SCHEDULER_URL" : "mongodb://mongo:27017"
}
celery.conf.update(confs)

@celery.task(bind=True, name="tasks.print_hello")
def print_hello(self):
    print("Hello")
    return {'message': 'Done'}

@celery.task(bind=True, name="tasks.get_sources_metadata")
def get_sources_metadata(self):
    return {'sources': ded.sources_metadata}

# bind=True to have the self parameter
@celery.task(bind=True, name="tasks.generate_book_from_recipe")
def generate_book_from_recipe(self, recipe):
    self.update_state(state='PROGRESS', meta={'message': 'Starting book generation'})
    ded.generate_book_from_recipe(recipe, task=self)
    return {'message': 'Book generation complete'}


