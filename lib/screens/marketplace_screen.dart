import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_state.dart';
import '../models/market_listing.dart';
import 'my_listings_screen.dart';

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
    String selectedBrand = "Yonex";
    XFile? selectedImage;
    Uint8List? selectedImageBytes;
    bool isUploading = false;

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
                    // Image Picker Section
                    _buildFormLabel("Racket Photo"),
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (image != null) {
                          final bytes = await image.readAsBytes();
                          setModalState(() {
                            selectedImage = image;
                            selectedImageBytes = bytes;
                          });
                        }
                      },
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1622),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedImageBytes != null
                                ? const Color(0xFF00F5D4)
                                : Colors.white.withValues(alpha: 0.08),
                            width: 1.5,
                          ),
                          image: selectedImageBytes != null
                              ? DecorationImage(
                                  image: MemoryImage(selectedImageBytes!),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withValues(alpha: 0.3),
                                    BlendMode.darken,
                                  ),
                                )
                              : null,
                        ),
                        child: selectedImageBytes != null
                            ? Stack(
                                children: [
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          selectedImage = null;
                                          selectedImageBytes = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.photo_library,
                                            color: Color(0xFF00F5D4),
                                            size: 16,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "Tap to change photo",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 40,
                                    color: const Color(0xFF00F5D4).withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "TAP TO UPLOAD PHOTO",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Orbitron',
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Supports PNG, JPG, JPEG",
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      fontSize: 11,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    // Category & Brand Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormLabel("Category"),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D1622),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    width: 1.5,
                                  ),
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
                                      fontSize: 14,
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormLabel("Brand"),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D1622),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    width: 1.5,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedBrand,
                                    dropdownColor: const Color(0xFF111C28),
                                    iconEnabledColor: const Color(0xFF00F5D4),
                                    isExpanded: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                    ),
                                    items: ["Yonex", "Li-Ning", "Victor", "Other"]
                                        .map((b) {
                                          return DropdownMenuItem(
                                            value: b,
                                            child: Text(b == "Other" ? "Others" : b),
                                          );
                                        })
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() {
                                          selectedBrand = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isUploading
                            ? null
                            : () async {
                                final price =
                                    double.tryParse(priceController.text) ?? 0.0;
                                final sellerId = Supabase
                                        .instance.client.auth.currentUser?.id ??
                                    '00000000-0000-0000-0000-000000000000';

                                String finalImageUrl =
                                    selectedCategory == "Footwear"
                                        ? "assets/images/market_shoes.png"
                                        : selectedCategory == "Bags"
                                            ? "assets/images/market_bag.png"
                                            : "assets/images/racket_volts3.png";

                                if (selectedImage != null &&
                                    selectedImageBytes != null) {
                                  try {
                                    setModalState(() {
                                      isUploading = true;
                                    });

                                    final fileName =
                                        '${DateTime.now().millisecondsSinceEpoch}_${selectedImage!.name}';
                                    await Supabase.instance.client.storage
                                        .from('marketplace-images')
                                        .uploadBinary(
                                          fileName,
                                          selectedImageBytes!,
                                          fileOptions: const FileOptions(
                                            contentType: 'image/jpeg',
                                            upsert: true,
                                          ),
                                        );

                                    finalImageUrl = Supabase
                                        .instance.client.storage
                                        .from('marketplace-images')
                                        .getPublicUrl(fileName);
                                  } catch (uploadErr) {
                                    debugPrint("Error uploading image: $uploadErr");
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor:
                                              const Color(0xFF111C28),
                                          content: Text(
                                            "Image upload failed: $uploadErr",
                                            style: const TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                        ),
                                      );
                                    }
                                    setModalState(() {
                                      isUploading = false;
                                    });
                                    return;
                                  }
                                }

                                final newListing = MarketListing(
                                  sellerId: sellerId,
                                  title: titleController.text.isNotEmpty
                                      ? titleController.text
                                      : "RacketBase Custom Racket",
                                  brand: selectedBrand,
                                  priceMyr: price,
                                  imageUrl: finalImageUrl,
                                  itemCondition:
                                      conditionController.text.isNotEmpty
                                          ? conditionController.text
                                          : "Used - Like New",
                                  location: locationController.text.isNotEmpty
                                      ? locationController.text
                                      : "Malaysia",
                                );

                                try {
                                  if (selectedImage == null) {
                                    setModalState(() {
                                      isUploading = true;
                                    });
                                  }
                                  await state.addMarketListing(newListing);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            const Color(0xFF111C28),
                                        content: Text(
                                          "Error listing item: $e",
                                          style: const TextStyle(
                                              color: Colors.redAccent),
                                        ),
                                      ),
                                    );
                                  }
                                  setModalState(() {
                                    isUploading = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00F5D4),
                          foregroundColor: const Color(0xFF0D1622),
                          disabledBackgroundColor:
                              const Color(0xFF00F5D4).withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF0D1622),
                                  ),
                                ),
                              )
                            : const Text(
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

  void _showListingDetailSheet(BuildContext context, MarketListing item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111C28),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _showBiggerImage(context, item.imagePath, item.title),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 240,
                    width: double.infinity,
                    color: const Color(0xFF0A0F18),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: item.imagePath.startsWith('http')
                              ? Image.network(
                                  item.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 50)),
                                )
                              : Image.asset(
                                  item.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 50)),
                                ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fullscreen,
                              color: Color(0xFF00F5D4),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (item.tag.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F5D4).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF00F5D4), width: 1),
                  ),
                  child: Text(
                    item.tag,
                    style: const TextStyle(
                      color: Color(0xFF00F5D4),
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Orbitron',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "RM ${item.price.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Color(0xFF00F5D4),
                  fontFamily: 'Orbitron',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white12),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailTile(Icons.history, "Condition", item.condition),
                  ),
                  Expanded(
                    child: _buildDetailTile(Icons.location_on_outlined, "Location", item.location),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailTile(Icons.category_outlined, "Category", item.category),
                  ),
                  Expanded(
                    child: _buildDetailTile(
                      Icons.calendar_today_outlined, 
                      "Posted On", 
                      item.createdAt != null 
                          ? "${item.createdAt!.day}/${item.createdAt!.month}/${item.createdAt!.year}" 
                          : "N/A"
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF111C28),
                        title: const Text(
                          "Contact Seller",
                          style: TextStyle(fontFamily: 'Orbitron', color: Color(0xFF00F5D4)),
                        ),
                        content: const Text(
                          "Chat integration is coming soon! For now, you can coordinate transactions through the standard community channels.",
                          style: TextStyle(fontFamily: 'Inter', color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK", style: TextStyle(color: Color(0xFF00F5D4))),
                          )
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text(
                    "CONTACT SELLER",
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00F5D4),
                    foregroundColor: const Color(0xFF0D1622),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // Visual helper method to display a listing's image in full screen with pinch-to-zoom
  void _showBiggerImage(BuildContext context, String imagePath, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF111C28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF00F5D4).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00F5D4),
                ),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.black38,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white24,
                              size: 64,
                            ),
                          ),
                        )
                      : Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.black38,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white24,
                              size: 64,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF00F5D4), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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
        title: const Text(
          "COMMUNITY MARKET",
          style: TextStyle(
            color: Color(0xFF00F5D4),
            fontFamily: 'Orbitron',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A0F18),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyListingsScreen()),
              );
            },
            child: const Text(
              "My Listing",
              style: TextStyle(
                color: Color(0xFF00F5D4),
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
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

                      return GestureDetector(
                        onTap: () => _showListingDetailSheet(context, item),
                        child: Container(
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
                                    child: item.imagePath.startsWith('http')
                                        ? Image.network(
                                            item.imagePath,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                                  color: Colors.black26,
                                                  child: const Icon(Icons.broken_image, color: Colors.white24),
                                                ),
                                          )
                                        : Image.asset(
                                            item.imagePath,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                                  color: Colors.black26,
                                                  child: const Icon(Icons.broken_image, color: Colors.white24),
                                                ),
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
