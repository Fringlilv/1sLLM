import pymongo

class DB:
    db = pymongo.MongoClient('mongodb://localhost:27017')['1sLLM']

    def __init__(self, set_name=None) -> None:
        self.db_set = DB.db[set_name]
        self._db_id = None
    
    def save(self):
        self.db_set.update_one({'_id': self._db_id}, {'$set': self.__dict__()}, upsert=True)

    def delete(self):
        self.db_set.delete_one({'_id': self._db_id})
    
    def _db_dict(self):
        raise NotImplementedError("Subclasses should implement this method.")
