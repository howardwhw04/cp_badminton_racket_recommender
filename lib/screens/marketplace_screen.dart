import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_state.dart';
import '../models/market_listing.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  void _showAddListingSheet(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final locationController = TextEditingController();
    final conditionController = TextEditingController(text: "Used - Like New");
    final durationController = TextEditingController(text: "3 Months Used");
    String selectedCategory = "Racquets";
    bool isElite = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111C28),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CREATE NEW LISTING",
                      style: TextStyle(
                        color: Color(0xFF00F5D4),
                        fontFamily: 'Orbitron',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Item Title
                    _buildFormLabel("Item Title"),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildFormDecoration(
                        "e.g. Yonex Nanoflare 1000Z",
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Price & Location
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormLabel("Price (RM)"),
                              TextField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildFormDecoration("e.g. 450"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormLabel("Location"),
                              TextField(
                                controller: locationController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildFormDecoration(
                                  "e.g. Petaling Jaya",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Condition & Usage
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormLabel("Condition"),
                              TextField(
                                controller: conditionController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildFormDecoration(
                                  "e.g. Used - Like New",
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormLabel("Usage Duration"),
                              TextField(
                                controller: durationController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildFormDecoration(
                                  "e.g. 6 Months Used",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Category dropdown
                    _buildFormLabel("Category"),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1622),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          dropdownColor: const Color(0xFF111C28),
                          iconEnabledColor: const Color(0xFF00F5D4),
                          isExpanded: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                          items: ["Racquets", "Footwear", "Bags", "Accessories"]
                              .map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                );
                              })
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedCategory = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Elite Tag Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Mark as Premium (ELITE tag)",
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Inter',
                            fontSize: 14,
                          ),
                        ),
                        Switch(
                          value: isElite,
                          activeThumbColor: const Color(0xFF00F5D4),
                          onChanged: (val) {
                            setModalState(() {
                              isElite = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          final price =
                              double.tryParse(priceController.text) ?? 0.0;
                          final sellerId = Supabase.instance.client.auth.currentUser?.id ?? '00000000-0000-0000-0000-000000000000';
                          final newListing = MarketListing(
                            sellerId: sellerId,
                            title: titleController.text.isNotEmpty
                                ? titleController.text
                                : "AEROCORE Custom Racket",
                            brand: selectedCategory == "Racquets" ? "Yonex" : "Other",
                            priceMyr: price,
                            imageUrl: selectedCategory == "Footwear"
                                ? "assets/images/market_shoes.png"
                                : selectedCategory == "Bags"
                                ? "assets/images/market_bag.png"
                                : "assets/images/racket_volts3.png",
                            itemCondition: conditionController.text.isNotEmpty
                                ? conditionController.text
                                : "Used - Like New",
                            location: locationController.text.isNotEmpty
                                ? locationController.text
                                : "Malaysia",
                          );
                          
                          try {
                            await state.addMarketListing(newListing);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF111C28),
                                  content: Text(
                                    "Error listing item: $e",
                                    style: const TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00F5D4),
                          foregroundColor: const Color(0xFF0D1622),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "SUBMIT LISTING",
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white30,
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  InputDecoration _buildFormDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF0D1622),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final filter = state.selectedMarketFilter;
    final items = state.marketplaceItems;

    // Filter items based on selected category
    final filteredItems = filter == "All Items"
        ? items
        : items.where((item) => item.category == filter).toList();

    final categories = ["All Items", "Racquets", "Footwear", "Bags"];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1622),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Community Market",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Orbitron',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Active listings in Malaysia",
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Inter',
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D1622),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Header Category Chips horizontal scroll
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = filter == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF0D1622)
                            : Colors.white70,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00F5D4),
                    backgroundColor: const Color(0xFF111C28),
                    onSelected: (_) {
                      state.selectMarketFilter(category);
                    },
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Product Masonry Grid (2 columns)
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      "No listings found in this category.",
                      style: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              0.58, // Adjust ratio for content details
                        ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF111C28),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Upper Image Frame
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  child: Container(
                                    height: 130,
                                    width: double.infinity,
                                    color: const Color(0xFF0A0F18),
                                    child: Image.asset(
                                      item.imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(color: Colors.black26),
                                    ),
                                  ),
                                ),
                                // Ribbon Tag top-left
                                if (item.tag.isNotEmpty)
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00F5D4),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.tag,
                                        style: const TextStyle(
                                          color: Color(0xFF0D1622),
                                          fontFamily: 'Orbitron',
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            // Details Section
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Orbitron',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    // Price RM
                                    Text(
                                      "RM ${item.price.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        color: Color(0xFF00F5D4),
                                        fontFamily: 'Orbitron',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Condition Details
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.history,
                                          color: Colors.white30,
                                          size: 13,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            item.condition,
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontFamily: 'Inter',
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Location Pin
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          color: Color(0xFF00F5D4),
                                          size: 13,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            item.location,
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.4,
                                              ),
                                              fontFamily: 'Inter',
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Overlay Floating Action Button in bottom right corner
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 76.0,
        ), // Above bottom bar padding
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF00F5D4),
          foregroundColor: const Color(0xFF0D1622),
          shape: const CircleBorder(),
          elevation: 6,
          onPressed: () => _showAddListingSheet(context),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}
