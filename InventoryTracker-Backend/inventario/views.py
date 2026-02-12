from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Q

from .models import InventoryItem
from .serializers import InventoryItemSerializer

class InventoryItemViewSet(viewsets.ModelViewSet):
    serializer_class = InventoryItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return InventoryItem.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=False, methods=["post"], url_path="purchase-preview")
    def purchase_preview(self, request):
        """
        Body esperado:
        {
          "name": "cebolla",
          "unit": "kg",
          "quantity": 2
        }
        """
        name = (request.data.get("name") or "").strip()
        unit = (request.data.get("unit") or "").strip()
        if not name or not unit:
            return Response({"detail": "name y unit son requeridos."}, status=status.HTTP_400_BAD_REQUEST)

        item = InventoryItem.objects.filter(
            user=request.user,
            name__iexact=name,
            unit=unit
        ).first()

        if item and item.quantity > 0:
            return Response({
                "exists": True,
                "currentQty": str(item.quantity),
                "unit": item.unit,
                "message": f"⚠️ Ya tienes {item.quantity} {item.unit} de {item.name}. ¿Estás seguro que necesitas más?"
            })

        return Response({"exists": False, "message": "OK"})
