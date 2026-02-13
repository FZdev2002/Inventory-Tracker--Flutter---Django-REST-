from django.conf import settings
from django.db import models


class InventoryItem(models.Model):
    class Unit(models.TextChoices):
        UNIDAD = "unidad", "unidad"
        KG = "kg", "kg"
        G = "g", "g"
        LB = "lb", "lb"
        LT = "lt", "lt"
        ML = "ml", "ml"
        DOCENA = "docena", "docena"
        CAJA = "caja", "caja"
        PAQUETE = "paquete", "paquete"

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="inventory_items"
    )
    name = models.CharField(max_length=120)
    unit = models.CharField(max_length=20, choices=Unit.choices, default=Unit.UNIDAD)
    quantity = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ("user", "name", "unit")
        ordering = ["name"]

    def __str__(self):
        return f"{self.name} ({self.quantity} {self.unit})"


class Purchase(models.Model):
    """
    Historial de compras (solo se crea cuando el usuario compra desde BuyPage).
    """
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="purchases"
    )
    name = models.CharField(max_length=120)
    unit = models.CharField(max_length=20)
    quantity = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.name} {self.quantity} {self.unit} ({self.created_at:%Y-%m-%d})"
