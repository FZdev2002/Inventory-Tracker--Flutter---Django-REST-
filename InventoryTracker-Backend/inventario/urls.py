from rest_framework.routers import DefaultRouter
from .views import InventoryItemViewSet, PurchaseViewSet

router = DefaultRouter()
router.register(r"items", InventoryItemViewSet, basename="inventory-items")
router.register(r"purchases", PurchaseViewSet, basename="purchases")

urlpatterns = router.urls
