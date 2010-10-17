import sqlalchemy as sa
from sqlalchemy.types import AbstractType, Integer
from sqlalchemy import orm

from chaosweb.model import meta

__models = []

# Monkey patched into Model-decorated classes
@classmethod
def relation(cls, *args, **kwargs):
	return orm.relation(cls, *args, **kwargs)

def Model(cls):
	cls.relation = relation
	__models.append(cls)
	return cls

def setup():
	for model in __models:
		params = []
		for field in dir(model):
			value = getattr(model, field)
			if isinstance(value, PrimaryKey):
				params = [field] + params
			else:
				params.append(field)
		
		columns = []
		relations = {}
		for field in params:
			value = getattr(model, field)
			if isinstance(value, Modifier):
				columns.append(value.build(field))
				delattr(model, field)
			elif (
					isinstance(value, AbstractType) or 
					(isinstance(value, type) and issubclass(value, AbstractType))
				):
				columns.append(sa.Column(field, value))
				delattr(model, field)
			elif isinstance(value, orm.properties.RelationProperty):
				relations[field] = value
				delattr(model, field)
		
		table = sa.Table(model.__name__, meta.metadata, *columns)
		orm.mapper(model, table, properties=relations)

class Modifier(object):
	pass

class PrimaryKey(Modifier):
	def __init__(self, type):
		self.type = type
	
	def build(self, name):
		return sa.Column(name, self.type, primary_key=True)

class ForeignKey(Modifier):
	def __init__(self, type, ref, *args, **kwargs):
		self.type, self.ref = type, ref
		self.args, self.kwargs = args, kwargs
	
	def build(self, name):
		return sa.Column(name, self.type, sa.ForeignKey(self.ref), *self.args, **self.kwargs)

class Nullable(Modifier):
	def __init__(self, type, *args, **kwargs):
		self.type = type
		self.args, self.kwargs = args, kwargs
	
	def build(self, name):
		return sa.Column(name, self.type, nullable=True, *self.args, **self.kwargs)

class Unique(Modifier):
	def __init__(self, type, *args, **kwargs):
		self.type = type
		self.args, self.kwargs = args, kwargs
	
	def build(self, name):
		return sa.Column(name, self.type, unique=True, *self.args, **self.kwargs)
