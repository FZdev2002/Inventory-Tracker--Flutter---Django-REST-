from django.conf import settings
from django.db import models

class InventoryItem(models.Model):
    class Unit(models.TextChoices):
        PCS = "pcs", "pcs"
        KG = "kg", "kg"
        LT = "lt", "lt"

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="inventory_items")
    name = models.CharField(max_length=120)
    unit = models.CharField(max_length=10, choices=Unit.choices, default=Unit.PCS)
    quantity = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ("user", "name", "unit")
        ordering = ["name"]

    def __str__(self):
        return f"{self.name} ({self.quantity} {self.unit})"
