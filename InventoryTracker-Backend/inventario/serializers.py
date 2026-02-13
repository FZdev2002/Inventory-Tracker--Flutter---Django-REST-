from rest_framework import serializers
from .models import InventoryItem, Purchase


class InventoryItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = InventoryItem
        fields = ["id", "name", "unit", "quantity", "updated_at"]
        read_only_fields = ["id", "updated_at"]


class PurchaseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Purchase
        fields = ["id", "name", "unit", "quantity", "created_at"]
        read_only_fields = ["id", "created_at"]
