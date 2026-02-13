from decimal import Decimal

from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import InventoryItem, Purchase
from .serializers import InventoryItemSerializer, PurchaseSerializer


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

        existing = InventoryItem.objects.filter(
            user=user, name__iexact=name, unit=unit
        ).first()

        if existing:
            existing.quantity = existing.quantity + Decimal(str(qty))
            existing.save()
            out = self.get_serializer(existing)
            return Response(out.data, status=status.HTTP_200_OK)

        serializer.save(user=user)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop("partial", False)
        instance: InventoryItem = self.get_object()

        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)

        user = request.user

        new_name = (serializer.validated_data.get("name", instance.name) or "").strip()
        new_unit = serializer.validated_data.get("unit", instance.unit)
        new_qty = serializer.validated_data.get("quantity", instance.quantity)

        other = InventoryItem.objects.filter(
            user=user,
            name__iexact=new_name,
            unit=new_unit
        ).exclude(id=instance.id).first()

        if other:
            other.quantity = other.quantity + Decimal(str(new_qty))
            other.name = new_name
            other.unit = new_unit
            other.save()

            instance.delete()

            out = self.get_serializer(other)
            return Response(out.data, status=status.HTTP_200_OK)

        instance.name = new_name
        instance.unit = new_unit
        instance.quantity = new_qty
        instance.save()

        out = self.get_serializer(instance)
        return Response(out.data, status=status.HTTP_200_OK)

    @action(detail=False, methods=["post"], url_path="purchase-preview")
    def purchase_preview(self, request):
        name = (request.data.get("name") or "").strip()
        unit = (request.data.get("unit") or "").strip()

        if not name or not unit:
            return Response({"detail": "name y unit son requeridos."},
                            status=status.HTTP_400_BAD_REQUEST)

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
            return Response({"detail": "name, unit y quantity son requeridos."},
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            qty = Decimal(str(qty_raw))
            if qty <= 0:
                return Response({"detail": "quantity debe ser > 0."},
                                status=status.HTTP_400_BAD_REQUEST)
        except Exception:
            return Response({"detail": "quantity inválida."},
                            status=status.HTTP_400_BAD_REQUEST)

        item = InventoryItem.objects.filter(
            user=request.user,
            name__iexact=name,
            unit=unit
        ).first()

        if item:
            item.quantity = item.quantity + qty
            item.save()
        else:
            item = InventoryItem.objects.create(
                user=request.user,
                name=name,
                unit=unit,
                quantity=qty
            )

        # ✅ historial
        Purchase.objects.create(
            user=request.user,
            name=name,
            unit=unit,
            quantity=qty
        )

        return Response({
            "ok": True,
            "id": item.id,
            "name": item.name,
            "unit": item.unit,
            "quantity": str(item.quantity),
        }, status=status.HTTP_200_OK)


class PurchaseViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = PurchaseSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Purchase.objects.filter(user=self.request.user)
