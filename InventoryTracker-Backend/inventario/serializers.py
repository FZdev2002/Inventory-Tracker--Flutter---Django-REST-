from rest_framework import serializers
from .models import InventoryItem

class InventoryItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = InventoryItem
        fields = ["id", "name", "unit", "quantity", "updated_at"]
        read_only_fields = ["id", "updated_at"]
