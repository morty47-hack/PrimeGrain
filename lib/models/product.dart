class Product {
  final String id;
  final String name;
  final String image;
  final double basePrice;
  final String description;
  final String pairing;

  const Product({
    required this.id,
    required this.name,
    required this.image,
    required this.basePrice,
    required this.description,
    required this.pairing,
  });
}

const List<Product> allProducts = [
  Product(
    id: '1',
    name: 'Red Cowpeas (Thoroco)',
    image: 'assets/images/thoroco_red.jpg',
    basePrice: 180,
    description: 'Nutrient-dense red cowpeas sourced from eastern Kenya.',
    pairing: 'Rice, stewed with onions and tomatoes.',
  ),
  Product(
    id: '2',
    name: 'Pigeon Peas (Baazi)',
    image: 'assets/images/baazi_njogu.jpg',
    basePrice: 200,
    description: 'Traditional large, nutty-flavored peas.',
    pairing: 'Boiled with maize (Githeri) or mashed.',
  ),
  Product(
    id: '3',
    name: 'Cotton Beans',
    image: 'assets/images/cotton_small.jpg',
    basePrice: 160,
    description: 'Small white beans with a creamy texture.',
    pairing: 'Sautéed with greens or in bean soup.',
  ),
  Product(
    id: '4',
    name: 'Gaki Beans',
    image: 'assets/images/gaki.jpg',
    basePrice: 190,
    description: 'Local speckled variety, very soft when cooked.',
    pairing: 'Ideal for Githeri or Mokimo.',
  ),
  Product(
    id: '5',
    name: 'Lentils (Kamande)',
    image: 'assets/images/kamande.jpg',
    basePrice: 220,
    description: 'Fast-cooking, high-protein brown lentils.',
    pairing: 'Served with Chapati or Rice.',
  ),
  Product(
    id: '6',
    name: 'Njahi (Lablab Beans)',
    image: 'assets/images/lablab_beans.jpg',
    basePrice: 240,
    description: 'Earthy black beans, popular in central Kenya.',
    pairing: 'Mashed with potatoes and green bananas.',
  ),
  Product(
    id: '7',
    name: 'Dry Maize',
    image: 'assets/images/maize.jpg',
    basePrice: 90,
    description: 'Grade 1 cleaned, high-quality white maize.',
    pairing: 'Combined with beans for Githeri.',
  ),
  Product(
    id: '8',
    name: 'Mukombi Beans',
    image: 'assets/images/mukombi.jpg',
    basePrice: 210,
    description: 'Distinct, tasty local bean variety.',
    pairing: 'Stews and traditional Kenyan mixes.',
  ),
  Product(
    id: '9',
    name: 'Nyayo Beans',
    image: 'assets/images/nyayo_beans.jpg',
    basePrice: 180,
    description: 'Popular long red kidney-style beans.',
    pairing: 'The standard for Githeri and rice-bean stews.',
  ),
  Product(
    id: '10',
    name: 'Nylon Beans',
    image: 'assets/images/nylon.jpg',
    basePrice: 175,
    description:
        'Shiny, smooth-textured beans that cook fast for busy kitchens.',
    pairing: 'Fast-boiling for quick commercial meals.',
  ),
  Product(
    id: '11',
    name: 'Mwea Pishori Rice',
    image: 'assets/images/pishori.jpg',
    basePrice: 250,
    description: 'Authentic aromatic long-grain rice from Mwea.',
    pairing: 'Beef stew, chicken, or plain with salt.',
  ),
  Product(
    id: '12',
    name: 'White Cowpeas',
    image: 'assets/images/thoroco_white.jpg',
    basePrice: 170,
    description: 'Creamy white cowpeas with a mild, sweet flavor.',
    pairing: 'Mixed with greens or mashed into porridge.',
  ),
  Product(
    id: '13',
    name: 'Western Ndengu Special',
    image: 'assets/images/western_ndengu_special.jpg',
    basePrice: 180,
    description: 'Polished, high-quality Makueni-style grams.',
    pairing: 'Best served with Coconut Rice or Chapati.',
  ),
  Product(
    id: '14',
    name: 'Yellow Bean',
    image: 'assets/images/yellow_bean.jpg',
    basePrice: 200,
    description: 'Non-acidic, easy-to-digest yellow beans.',
    pairing: 'Highly popular for stews; very tasty.',
  ),
];

