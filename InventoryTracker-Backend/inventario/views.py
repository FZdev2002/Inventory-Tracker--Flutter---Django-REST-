from decimal import Decimal

from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import InventoryItem
from .serializers import InventoryItemSerializer


class InventoryItemViewSet(viewsets.ModelViewSet):
    serializer_class = InventoryItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return InventoryItem.objects.filter(user=self.request.user)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = request.user
        name = (serializer.validated_data.get("name") or "").strip()
        unit = serializer.validated_data.get("unit")
        qty = serializer.validated_data.get("quantity")

        # Busca si ya existe el item con misma unidad
        existing = InventoryItem.objects.filter(
            user=user,
            name__iexact=name,
            unit=unit
        ).first()

        if existing:
            existing.quantity = existing.quantity + Decimal(str(qty))
            existing.save()

            out = self.get_serializer(existing)
            return Response(out.data, status=status.HTTP_200_OK)

        # No existe: crea normal
        serializer.save(user=user)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    @action(detail=False, methods=["post"], url_path="purchase-preview")
    def purchase_preview(self, request):
        name = (request.data.get("name") or "").strip()
        unit = (request.data.get("unit") or "").strip()

        if not name or not unit:
            return Response(
                {"detail": "name y unit son requeridos."},
                status=status.HTTP_400_BAD_REQUEST
            )

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

    @action(detail=False, methods=["post"], url_path="purchase-confirm")
    def purchase_confirm(self, request):
        name = (request.data.get("name") or "").strip()
        unit = (request.data.get("unit") or "").strip()
        qty_raw = request.data.get("quantity")

        if not name or not unit or qty_raw is None:
            return Response(
                {"detail": "name, unit y quantity son requeridos."},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            qty = Decimal(str(qty_raw))
            if qty <= 0:
                return Response({"detail": "quantity debe ser > 0."}, status=status.HTTP_400_BAD_REQUEST)
        except Exception:
            return Response({"detail": "quantity inválida."}, status=status.HTTP_400_BAD_REQUEST)

        item = InventoryItem.objects.filter(
            user=request.user,
            name__iexact=name,
            unit=unit
        ).first()

        if item:
            item.quantity = item.quantity + qty
            item.save()
            return Response({
                "updated": True,
                "id": item.id,
                "name": item.name,
                "unit": item.unit,
                "quantity": str(item.quantity),
            }, status=status.HTTP_200_OK)

        new_item = InventoryItem.objects.create(
            user=request.user,
            name=name,
            unit=unit,
            quantity=qty
        )
        return Response({
            "created": True,
            "id": new_item.id,
            "name": new_item.name,
            "unit": new_item.unit,
            "quantity": str(new_item.quantity),
        }, status=status.HTTP_201_CREATED)
