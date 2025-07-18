import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';


class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  final FocusNode _focusNode = FocusNode(debugLabel: 'MarketplaceFocusNode');
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    // Delay focus operations until after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.canRequestFocus = true;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusScopeNode.dispose();
    super.dispose();
  }

  void _showFullImage(BuildContext context, String imageUrl) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      );
    }


  Future<void> _showSellDialog(BuildContext context) async {
  if (_isDialogOpen) {
    return;
  }
  _isDialogOpen = true;

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await showDialog(
      context: context,
      builder: (_) => _SellItemDialog(
        supabase: _supabase,
        picker: _picker,
        onDismiss: () => _isDialogOpen = false,
      ),
    );
    _isDialogOpen = false;
  });
}

  Future<List<Map<String, dynamic>>> _fetchMarketplaceItems() async {
  try {
    final response = await _supabase
        .from('marketplace_items')
        .select('*, students(name, student_number, institution)')
        .order('created_at', ascending: false);

    // Get the public URLs for all images
    final itemsWithUrls = await Future.wait(response.map((item) async {
      // Extract the filename from the stored path (e.g., "marketplace/12345_image.jpg")
      final imagePath = item['image_url'] as String;
      
      // Get public URL
      final imageUrl = _supabase.storage
          .from('items-images')
          .getPublicUrl(imagePath);

      return {
        ...item,
        'image_url': imageUrl,
      };
    }));

    return itemsWithUrls;
  } catch (e) {
    debugPrint('Error fetching items: $e');
    return [];
  }
}

  Widget _buildListingItem({
    required String imageUrl,
    required String price,
    required String location,
    required String description,
    required String sellerName,
    required String studentNumber,
    required String institution,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GestureDetector(
                    onTap: () => _showFullImage(context, imageUrl),
                    child: Image.network(
                      imageUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Price: $price",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Location: $location",
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text(description,
                          maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _showSellerInfo(context, sellerName, studentNumber, institution),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Inquire',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSellerInfo(
    BuildContext context,
    String name,
    String studentNumber,
    String institution,
    ) {
      final email = "$studentNumber@${institution.replaceAll(' ', '')}.co.za";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Seller Info"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: $name"),
              const SizedBox(height: 8),
              Text("Email: $email"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    });
  }

  // Add a state variable to trigger refresh
  int _refreshKey = 0;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _focusScopeNode,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Marketplace'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ElevatedButton(
                onPressed: () => _showSellDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Sell an Item'),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: (Colors.blue[900] ?? Colors.blue).withAlpha((0.2 * 255).toInt()),
                          blurRadius: 40,
                          spreadRadius: 0,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      'assets/images/water_drop.svg',
                      height: 100,
                      width: 100,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'TapsOnApp',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      height: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  // Use the refresh key to trigger a new future
                  key: ValueKey(_refreshKey),
                  future: _fetchMarketplaceItems(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return const Center(child: Text('No items listed yet.'));
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        if (mounted) {
                          setState(() {
                            _refreshKey++;
                          });
                        }
                        return;
                      },
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildListingItem(
                            imageUrl: item['image_url'],
                            price: item['price'],
                            location: item['location'],
                            description: item['description'],
                            sellerName: item['students']?['name'] ?? 'Unknown',
                            studentNumber: item['students']?['student_number'] ?? 'N/A',
                            institution: item['students']?['institution'] ?? 'N/A',
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  

class _SellItemDialog extends StatefulWidget {
  final SupabaseClient supabase;
  final ImagePicker picker;
  final VoidCallback onDismiss;

  const _SellItemDialog({
    required this.supabase,
    required this.picker,
    required this.onDismiss,
  });

  @override
  _SellItemDialogState createState() => _SellItemDialogState();
}

class _SellItemDialogState extends State<_SellItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  XFile? _selectedImage;
  bool _isLoading = false;
  Uint8List? _imageBytes;

 Future<void> _pickImage() async {
  try {
    final image = await widget.picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _imageBytes = bytes;
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }
}


  Future<void> _submitItem() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload an image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final fileName = 'marketplace/${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.name}';

      await widget.supabase.storage
          .from('items-images')
          .uploadBinary(fileName, bytes);


      final user = widget.supabase.auth.currentUser;
      if (user != null) {
        await widget.supabase.from('marketplace_items').insert({
          'seller_id': user.id,
          'image_url': fileName,
          'price': _priceController.text.trim(),
          'location': _locationController.text.trim(),
          'description': _descriptionController.text.trim(),
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item posted successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Sell an Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _imageBytes != null
              ? Image.memory(
                  _imageBytes!,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                )
              : const Text('No image selected'),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Upload Image'),
              onPressed: _isLoading ? null : _pickImage,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Enter price' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) => value!.isEmpty ? 'Enter location' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) => value!.isEmpty ? 'Enter description' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () {
            Navigator.pop(context);
            widget.onDismiss();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitItem,
          child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Post'),
        ),
      ],
    );
  }
}
