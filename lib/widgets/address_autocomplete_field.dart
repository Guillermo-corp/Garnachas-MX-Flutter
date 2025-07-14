import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/google_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String calle, String cp, String ciudad)? onAddressSelected;
  final String apiKey;
  final String label;
  final Function(String)? onSelected;

  const AddressAutocompleteField({
    super.key,
    required this.controller,
    this.onAddressSelected,
    required this.apiKey,
    this.label = 'Dirección',
    this.onSelected,
  });

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];

  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  late final GeocodingService _geoService;

  @override
  void initState() {
    super.initState();
    _geoService = GeocodingService(widget.apiKey);

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _showOverlay() async {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5,
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: _suggestions
                  .map(
                    (s) => ListTile(
                      title: Text(s),
                      onTap: () async {
                        widget.controller.text = s;
                        widget.onSelected?.call(s);
                        _removeOverlay();
                        _focusNode.unfocus();

                        final coords = await _geoService.getLatLngFromAddress(
                          s,
                        );
                        print('📍 Coordenadas obtenidas: $coords');
                        if (coords != null) {
                          setState(() {
                            _selectedLocation = LatLng(
                              coords['lat'],
                              coords['lng'],
                            );
                          });

                          _mapController?.animateCamera(
                            CameraUpdate.newLatLng(_selectedLocation!),
                          );

                          final details = await _geoService
                              .getAddressDetailsFromLatLng(
                                coords['lat'],
                                coords['lng'],
                              );

                          if (details != null) {
                            widget.onAddressSelected?.call(
                              details['calle'] ?? '',
                              details['cp'] ?? '',
                              details['ciudad'] ?? '',
                            );
                          }
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _updateSuggestions(String input) async {
    if (input.length < 3) {
      _removeOverlay();
      setState(() => _suggestions = []);
      return;
    }

    final results = await _geoService.getAddressSuggestions(input);
    if (results.isNotEmpty) {
      setState(() => _suggestions = results);
      if (_overlayEntry == null) {
        _showOverlay();
      } else {
        _overlayEntry!.markNeedsBuild();
      }
    } else {
      _removeOverlay();
      setState(() => _suggestions = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.location_on),
              labelText: widget.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            maxLines: 2,
            onChanged: _updateSuggestions,
            validator: (value) =>
                value == null || value.isEmpty ? 'Campo requerido' : null,
          ),
        ),
        const SizedBox(height: 10),
        if (_selectedLocation != null)
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation!,
                  zoom: 16,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('ubicacion-seleccionada'),
                    position: _selectedLocation!,
                    draggable: true,
                    onDragEnd: (newPosition) async {
                      setState(() {
                        _selectedLocation = newPosition;
                      });
                      final details = await _geoService
                          .getAddressDetailsFromLatLng(
                            newPosition.latitude,
                            newPosition.longitude,
                          );
                      if (details != null && widget.onAddressSelected != null) {
                        widget.onAddressSelected!(
                          details['calle'] ?? '',
                          details['cp'] ?? '',
                          details['ciudad'] ?? '',
                        );
                        // Opcional: actualiza el campo de texto principal
                        widget.controller.text =
                            '${details['calle'] ?? ''}, ${details['cp'] ?? ''}, ${details['ciudad'] ?? ''}';
                      }
                    },
                  ),
                },
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                onTap: (latLng) async {
                  setState(() {
                    _selectedLocation = latLng;
                  });
                  final details = await _geoService.getAddressDetailsFromLatLng(
                    latLng.latitude,
                    latLng.longitude,
                  );
                  if (details != null && widget.onAddressSelected != null) {
                    widget.onAddressSelected!(
                      details['calle'] ?? '',
                      details['cp'] ?? '',
                      details['ciudad'] ?? '',
                    );
                    widget.controller.text =
                        '${details['calle'] ?? ''}, ${details['cp'] ?? ''}, ${details['ciudad'] ?? ''}';
                  }
                },
              ),
            ),
          ),
          
      ],
    );
  }
}
