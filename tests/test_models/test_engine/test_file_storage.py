#!/usr/bin/python3

"""
Unit test suite for the FileStorage module
"""

import os
import unittest
import uuid
import json
from time import sleep
from datetime import datetime
from models.base_model import BaseModel
from models.engine.file_storage import FileStorage

class TestFileStorage(unittest.TestCase):
    """
    This class contains tests for the storage methods within FileStorage
    """
    
    def setUp(self):
        """
        Initialize a FileStorage instance for testing
        """
        self.storage = FileStorage()
        
    def test_storage_methods(self):
        """
        Test the functionality of various storage methods
        """
        # Obtain relevant attributes
        storage_dict = FileStorage.__dict__
        file_path_attr = '_FileStorage__file_path'
        objects_attr = '_FileStorage__objects'
        file_path = storage_dict[file_path_attr]
        objects_dict = storage_dict[objects_attr]

        # Assert types of attributes
        self.assertTrue(isinstance(file_path, str) and file_path)
        self.assertTrue(isinstance(objects_dict, dict))

        # Assert object attributes
        self.assertTrue(hasattr(self.storage, file_path_attr))
        self.assertTrue(getattr(self.storage, objects_attr) is self.storage.all())

        # Clear objects_dict for testing
        objects_dict.clear()

        # Object registration and persistent __objects dict
        original_objects = self.storage.all()
        original_objects_copy = original_objects.copy()
        new_obj = BaseModel()
        self.storage.new(new_obj)
        self.assertTrue(original_objects is self.storage.all())
        self.assertEqual(len(original_objects.keys()), 1)
        self.assertTrue(set(self.storage.all().keys()).difference(set(original_objects_copy.keys())) ==
                        {'BaseModel.{}'.format(new_obj.id)})

        original_objects_copy = original_objects.copy()
        # storage.new(obj)
        self.assertTrue(original_objects is self.storage.all())
        self.assertEqual(original_objects, original_objects_copy)

        new_obj = BaseModel()
        self.storage.new(new_obj)
        self.assertEqual(len(original_objects.keys()), 2)

        # Check serialization
        original_objects_copy = original_objects.copy()
        self.storage.save()
        self.assertTrue(os.path.isfile(file_path))
        with open(file_path, 'r') as file:
            json_objects = json.load(file)
            self.assertTrue(isinstance(json_objects, dict))
            self.assertEqual(len(json_objects.keys()), 2)
            self.assertTrue(all(v in original_objects.keys() for v in json_objects.keys()))

        self.storage.all().clear()
        self.storage.reload()

        # Copy the storage's objects and convert them to dictionaries
        original_objects_copy = self.storage.all().copy()

        # Check deserialization
        original_objects_copy = self.storage.all().copy()
        deserialized_objects_copy = self.storage.all().copy()
        self.assertEqual(original_objects_copy, deserialized_objects_copy)
        self.assertEqual(original_objects_copy, deserialized_objects_copy)

        # Check absence of deserialization for missing file
        original_objects_copy = self.storage.all().copy()
        os.remove(file_path)
        self.storage.reload()
        self.assertEqual(original_objects_copy, self.storage.all())

        # Automatic registration for instances created without args
        new_obj = BaseModel()
        obj_key = 'BaseModel.{}'.format(new_obj.id)
        self.assertTrue(obj_key in self.storage.all() and self.storage.all()[obj_key] is new_obj)
        sleep(.01)
        current_time = datetime.utcnow()
        new_obj.updated_at = current_time
        new_obj.save()
        self.storage.all().clear()
        self.storage.reload()
        updated_objects = self.storage.all()
        self.storage.reload()  # Insignificant reload
        updated_objects2 = self.storage.all()

        # Same deserialization
        self.assertEqual(new_obj.to_dict(), self.storage.all()[obj_key].to_dict())
        self.assertFalse(new_obj is self.storage.all()[obj_key].to_dict())

        # Args should not count towards manual instantiation
        new_obj = BaseModel(1, 2, 3)
        obj_key = 'BaseModel.{}'.format(new_obj.id)
        self.assertTrue(obj_key in self.storage.all() and self.storage.all()[obj_key] is new_obj)

        # Instances constructed with kwargs are not registered
        new_obj = BaseModel(id=str(uuid.uuid4()), created_at=current_time.isoformat(),
                            updated_at=current_time.isoformat())
        obj_key = 'BaseModel.{}'.format(new_obj.id)
        self.assertFalse(obj_key in self.storage.all())
        self.assertFalse(new_obj in self.storage.all().values())


if __name__ == "__main__":
    unittest.main()
