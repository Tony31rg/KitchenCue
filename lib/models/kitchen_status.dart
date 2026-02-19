enum KitchenStatus { ready, busy }

extension KitchenStatusX on KitchenStatus {
  bool get isBusy => this == KitchenStatus.busy;
  String get label => this == KitchenStatus.busy ? 'Busy' : 'Ready';
}
