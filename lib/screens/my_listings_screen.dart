import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_state.dart';
import '../models/market_listing.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  void _showEditListingSheet(BuildContext context, MarketListing listing) {
    final state = Provider.of<AppState>(context, listen: false);
    final titleController = TextEditingController(text: listing.title);
    final priceController = TextEditingController(text: listing.priceMyr.toStringAsFixed(0));
    final locationController = TextEditingController(text: listing.location);
    final conditionController = TextEditingController(text: listing.itemCondition);
    final durationController = TextEditingController(text: "3 Months Used"); // local placeholder field
    String selectedCategory = listing.category;
    String selectedBrand = listing.brand;
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "EDIT LISTING",
                          style: TextStyle(
                            color: Color(0xFF00F5D4),
                            fontFamily: 'Orbitron',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                            color: const Color(0xFF00F5D4),
                            width: 1.5,
                          ),
                          image: selectedImageBytes != null
                              ? DecorationImage(
                                  image: MemoryImage(selectedImageBytes!),
                                  fit: BoxFit.cover,
                                )
                              : (listing.imageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: listing.imageUrl.startsWith('http')
                                          ? NetworkImage(listing.imageUrl) as ImageProvider
                                          : AssetImage(listing.imageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
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
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isUploading
                            ? null
                            : () async {
                                final price =
                                    double.tryParse(priceController.text) ?? 0.0;
                                final sellerId = listing.sellerId;

                                String finalImageUrl = listing.imageUrl;

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

                                final updatedListing = MarketListing(
                                  id: listing.id,
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
                                  createdAt: listing.createdAt,
                                );

                                try {
                                  setModalState(() {
                                    isUploading = true;
                                  });
                                  await state.updateMarketListing(updatedListing);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Listing updated successfully!"),
                                        backgroundColor: Color(0xFF111C28),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            const Color(0xFF111C28),
                                        content: Text(
                                          "Error updating listing: $e",
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
                                "SAVE CHANGES",
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Delete Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: isUploading
                            ? null
                            : () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: const Color(0xFF111C28),
                                      title: const Text(
                                        "DELETE LISTING",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontFamily: 'Orbitron',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: const Text(
                                        "Are you sure you want to permanently delete this listing? This action cannot be undone.",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text(
                                            "CANCEL",
                                            style: TextStyle(color: Colors.white54),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text(
                                            "DELETE",
                                            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  try {
                                    setModalState(() {
                                      isUploading = true;
                                    });
                                    await state.deleteMarketListing(listing.id!);
                                    if (context.mounted) {
                                      Navigator.pop(context); // Close sheet
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Listing deleted successfully."),
                                          backgroundColor: Color(0xFF111C28),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Failed to delete listing: $e"),
                                          backgroundColor: const Color(0xFF111C28),
                                        ),
                                      );
                                    }
                                    setModalState(() {
                                      isUploading = false;
                                    });
                                  }
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent, width: 1.5),
                          foregroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "DELETE LISTING",
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
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final myListings = state.marketplaceItems.where((item) => item.sellerId == currentUserId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1622),
      appBar: AppBar(
        title: const Text(
          "MY LISTINGS",
          style: TextStyle(
            color: Color(0xFF00F5D4),
            fontFamily: 'Orbitron',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A0F18),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00F5D4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: myListings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.storefront,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You haven't listed any items yet.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontFamily: 'Inter',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the '+' button in the Market to sell your gear!",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontFamily: 'Inter',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: myListings.length,
              itemBuilder: (context, index) {
                final item = myListings[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111C28),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _showEditListingSheet(context, item),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 80,
                                width: 80,
                                color: const Color(0xFF0A0F18),
                                child: item.imagePath.startsWith('http')
                                    ? Image.network(
                                        item.imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image, color: Colors.white24),
                                      )
                                    : Image.asset(
                                        item.imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image, color: Colors.white24),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Orbitron',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (item.tag.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00F5D4),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.tag,
                                            style: const TextStyle(
                                              color: Color(0xFF0D1622),
                                              fontFamily: 'Orbitron',
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "RM ${item.price.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      color: Color(0xFF00F5D4),
                                      fontFamily: 'Orbitron',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.history, color: Colors.white30, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.condition,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.location_on_outlined, color: Color(0xFF00F5D4), size: 12),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item.location,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.4),
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
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.edit_note,
                              color: Color(0xFF00F5D4),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
