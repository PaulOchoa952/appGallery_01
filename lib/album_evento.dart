import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:video2u3/serviciosremotos.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AlbumEvento extends StatefulWidget {
  var datos;
  String usuario;
  AlbumEvento({super.key, required this.datos, required this.usuario});

  @override
  State<AlbumEvento> createState() => _AlbumEventoState();
}

class _AlbumEventoState extends State<AlbumEvento> {
  String name = "";
  String idEvento = "";
  bool admin = false;
  bool fecha = false;
  bool fechapaso=false;

  @override
  void initState() {
    // TODO: implement initState
    buscarAdmin();
    idEvento = widget.datos["id"];
    fecha = !widget.datos["estado"];
    if(widget.datos["admin"] == widget.usuario){
      setState(() {
        admin = true;
      });
    }
    super.initState();
  }

  void buscarAdmin() async{
    String admin = widget.datos["admin"];
    String nameAdmin = await DB.buscarAdminEvento(admin);
    setState(() {
      name = nameAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Album del Evento"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Imagenes", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: FutureBuilder(
                        future: DB.mostrarAlbum(idEvento),
                        builder: (context, img) {
                          if(img.hasData){
                            if(img.data!.items.length == 0){
                              return Container(
                                height: 250,
                                child: Center(child: Text("NO HAY IMAGENES\n\nEN EL ALBUM", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,))
                              );
                            } else {
                              return GestureDetector(
                                onTap: () async{
                                  await Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => Galeria(idEvento: idEvento, admin: admin)
                                  ));
                                  setState(() {});
                                },
                                child: CarouselSlider.builder(
                                    options: CarouselOptions(
                                      height: 250,
                                      viewportFraction: 1,
                                      enableInfiniteScroll: true,
                                      autoPlay: true,
                                      autoPlayInterval: Duration(seconds: 3),
                                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                                      autoPlayCurve: Curves.fastOutSlowIn,
                                      enlargeCenterPage: true,
                                      scrollDirection: Axis.horizontal,
                                    ),
                                    itemCount: img.data!.items.length,
                                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex){
                                      return FutureBuilder(
                                          future: DB.obtenerURLimagen(img.data!.items[itemIndex].name, idEvento),
                                          builder: (context, url) {
                                            if(url.hasData){
                                              return Container(
                                                child: Image.network(url.data!, fit: BoxFit.cover, width: double.infinity, height: 200, ),
                                              );
                                            }
                                            return Center(child: CircularProgressIndicator(),);
                                          }
                                      );
                                    }
                                ),
                              );
                            }
                          }else{
                            return Center(child: CircularProgressIndicator(),);
                          }
                        },
                    ),
                  ),
                  ListTile(
                    title: Text("${widget.datos["tipoEvento"]}", textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                    subtitle: Text("Propiedad de: ${name}", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                  ),
                  Divider(),
                  Text("${widget.datos["descipcion"]}", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  SizedBox(height: 20,),
                  Visibility(
                    visible: admin,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Cerrar Album", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                          SizedBox(height: 20,),
                          Switch(
                            value: fecha,
                            onChanged: (bool value) async {
                              print("valor del switch a $value");
                              print(widget.datos["id"]);
                              print(!widget.datos["estado"]);
                              await DB.actualizarEstadoDocumento(idEvento, !value).then((valuer){
                                print(valuer);
                                if(valuer == 0){
                                  setState(() {
                                    fecha = value;
                                  });
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{

          if(!fecha){
            final archivoAEnviar = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                type: FileType.custom,
                allowedExtensions: ["png", "jpg", "jpeg"]
            );
            if(archivoAEnviar==null){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No se selecciono ninguna imagen"), duration: Duration(seconds: 1),));
              return;
            }

            var path = archivoAEnviar.files.single.path!!;
            var nombre = archivoAEnviar.files.single.name!!;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Subiendo Imagen"), duration: Duration(seconds: 1),));

            DB.subirImagenAlbum(path, nombre, idEvento).then((value){
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Imagen subida satisfactoriamente"), duration: Duration(seconds: 1),));
            });

          }else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Album cerrado o fecha pasada"), duration: Duration(seconds: 1),));
          }

        },
        child: Icon(Icons.upload),
      ),
    );
  }

}

/////////////////////////////////////////////////////////
// Pantalla donde se muestra todas las imagenes

class Galeria extends StatefulWidget {
  String idEvento;
  bool admin;
  Galeria({super.key, required this.idEvento, required this.admin});

  @override
  State<Galeria> createState() => _GaleriaState();
}

class _GaleriaState extends State<Galeria> {
  @override
  late bool loading;
  List imagenes = [];

  @override
  void initState() {
    // TODO: implement initState
    loading = false;
    cargarURL();
    super.initState();
  }

  void cargarURL() async{
    var temp = await DB.mostrarAlbum(widget.idEvento);
    temp.items.forEach((element) async{
      String url = await DB.obtenerURLimagen(element.name, widget.idEvento);
      setState(() {
        imagenes.add(url);
      });
    });
    setState(() {
      loading = true;
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Album"),
        centerTitle: true,
      ),
      body: loading ? GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () async{
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ImagenesPagina(imagenes, index, widget.idEvento, widget.admin)
                ));
                setState(() {
                  imagenes = imagenes;
                });
              },
              child: Image.network(imagenes[index], width: 300, height: 300, fit: BoxFit.cover,)

          );
        },
        itemCount: imagenes.length,
      ) : Center(child: CircularProgressIndicator(),),
    );
  }

}

// Pantalla donde muestra una imagen especifica
class ImagenesPagina extends StatefulWidget {
  List imagenes;
  String idEvento;
  bool admin;
  int index;
  ImagenesPagina(this.imagenes, this.index, this.idEvento, this.admin);

  @override
  State<ImagenesPagina> createState() => _ImagenesPaginaState();
}

class _ImagenesPaginaState extends State<ImagenesPagina> {
  int _indice = 0;
  @override
  void initState() {
    // TODO: implement initState
    _indice = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
          child: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                controller: PhotoViewController(initialPosition: Offset.zero),
                imageProvider: NetworkImage(widget.imagenes[index]),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 1.8,
                heroAttributes: PhotoViewHeroAttributes(tag: index),
              );
            },
            itemCount: widget.imagenes.length,
            pageController: PageController(initialPage: widget.index),
            onPageChanged: (valor) {
              setState(() {
                _indice = valor;
              });
            },
            loadingBuilder: (context, event) => Center(
              child: Container(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(),
              ),
            ),
          )
      ),
      bottomNavigationBar: Visibility(
        visible: widget.admin,
        child: BottomAppBar(
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: () async{
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Eliminar Imagen"),
                          content: Text("¿Esta seguro que desea eliminar la imagen?"),
                          actions: [
                            TextButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                child: Text("Cancelar")
                            ),
                            TextButton(
                                onPressed: () async{
                                  String nombre = await DB.obtenerNombre(widget.imagenes[_indice]);
                                  DB.eliminarImagenAlbum(nombre, widget.idEvento).then((value) {
                                    Navigator.pop(context);
                                    if(widget.imagenes.length == _indice+1){
                                      setState(() {
                                        widget.imagenes.removeAt(_indice);
                                      });
                                      _indice = _indice-1;
                                    }else{
                                      setState(() {
                                        widget.imagenes.removeAt(_indice);
                                      });
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Imagen eliminada satisfactoriamente"), duration: Duration(seconds: 1),));
                                    if(widget.imagenes.length == 0){
                                      Navigator.pop(context);
                                    }
                                  });
                                },
                                child: Text("Aceptar")
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.delete_outline, color: Colors.white,),
              ),
              IconButton(onPressed: (){
                FileDownloader.downloadFile(url: widget.imagenes[_indice],

                    onDownloadCompleted: (value){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Imagen Descargada"), duration: Duration(seconds: 1),));
                    },
                    onDownloadError: (error){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al descargar"), duration: Duration(seconds: 1),));
                    });
              }, icon: Icon(Icons.download, color: Colors.white,))
            ],
          ),
        ),
      ),
    );
  }
}