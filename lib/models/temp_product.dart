// Model of a product... but its fields are non-final... helps very much when getting form input.
import '../providers/product.dart' show Product;

class TempProduct {
  String id;
  String title;
  String description;
  double price;
  String imageUrl;
  bool isFavorite;

  TempProduct({
    this.id,
    this.title,
    this.description,
    this.price,
    this.imageUrl,
    this.isFavorite,
  });

  Product toProduct() {
    return Product(
      id: this.id,
      title: this.title,
      description: this.description,
      price: this.price,
      imageUrl: this.imageUrl,
      isFavorite: this.isFavorite != null ? this.isFavorite : false,
    );
  }
}
