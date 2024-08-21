$(document).ready(function() {
      // Función para gestionar producto
    function gestionarProducto(accion) {
        const data = {
            accion: accion,
            UPC: $('#UPC').val(),
            nombre: $('#nombre').val(),
            tamaño: $('#tamaño').val(),
            embalaje: $('#embalaje').val(),
            marca: $('#marca').val(),
            id_Tipo: $('#id_Tipo').val()
        };

        $.post('php/productos.php', data, function (response) {
            alert(response);
            $('#productoForm')[0].reset(); // Limpiar el formulario
            location.reload(); // Recargar la lista de productos
        });
    }

    // Agregar producto
    $('#btnAgregarProducto').click(function () {
        gestionarProducto('create');
    });

    // Modificar producto
    $('#btnModificarProducto').click(function () {
        gestionarProducto('update');
    });

    // Eliminar producto
    $('#btnEliminarProducto').click(function () {
        gestionarProducto('delete');
    });

    // Cargar productos al inicio
    $.ajax({
        url: 'php/cargarProductos.php',
        method: 'GET',
        dataType: 'json',
        success: function(data) {
            var list = $('#productosList');
            list.empty();
            if (Array.isArray(data)) {
                data.forEach(function(producto) {
                    list.append(`<li>UPC: ${producto.UPC}, Nombre: ${producto.nombre}, Tamaño: ${producto.tamaño}, Embalaje: ${producto.embalaje}, Marca: ${producto.marca}</li>`);
                });
            } else {
                list.append('<li>Error: Los datos no están en el formato esperado.</li>');
            }
        },
        error: function() {
            alert('Error al cargar productos.');
        }
    });





        
        // Función para gestionar cliente
    function gestionarCliente(accion) {
        const data = {
            accion: accion,
            id_Cliente: $('#id_Cliente').val(),
            nombre1: $('#nombre1').val(),
            nombre2: $('#nombre2').val(),
            apellido1: $('#apellido1').val(),
            apellido2: $('#apellido2').val(),
            email: $('#email').val()
        };

        $.post('php/clientes.php', data, function (response) {
            alert(response);
            $('#clienteForm')[0].reset(); // Limpiar el formulario
            location.reload(); // Recargar la lista de clientes
        });
    }

    // Agregar cliente
    $('#btnAgregarCliente').click(function () {
        gestionarCliente('create');
    });

    // Modificar cliente
    $('#btnModificarCliente').click(function () {
        gestionarCliente('update');
    });

    // Eliminar cliente
    $('#btnEliminarCliente').click(function () {
        gestionarCliente('delete');
    });

    // Cargar clientes al inicio
    $.ajax({
        url: 'php/cargarClientes.php',
        method: 'GET',
        dataType: 'json',
        success: function(data) {
            var list = $('#clientesList');
            list.empty();
            if (Array.isArray(data)) {
                data.forEach(function(cliente) {
                    list.append(`<li>ID: ${cliente.id_Cliente}, Nombre: ${cliente.nombre1} ${cliente.nombre2} ${cliente.apellido1} ${cliente.apellido2}, Email: ${cliente.email}</li>`);
                });
            } else {
                list.append('<li>Error: Los datos no están en el formato esperado.</li>');
            }
        },
        error: function() {
            alert('Error al cargar clientes.');
        }
    });    








           // Mostrar u ocultar la selección de cliente basado en el reporte seleccionado
    $('#reporte').change(function () {
        if ($(this).val() === 'comprasCliente') {
            $('#seleccionCliente').show();

            // Cargar los clientes en el desplegable
            $.ajax({
                url: 'php/cargarClientes.php',
                method: 'GET',
                dataType: 'json',
                success: function(data) {
                    var clienteSelect = $('#idCliente');
                    clienteSelect.empty();
                    clienteSelect.append('<option value="">Seleccione un cliente</option>');
                    data.forEach(function(cliente) {
                        clienteSelect.append(`<option value="${cliente.id_Cliente}">${cliente.nombre1} ${cliente.apellido1}</option>`);
                    });
                },
                error: function() {
                    alert('Error al cargar los clientes.');
                }
            });

        } else {
            $('#seleccionCliente').hide();
        }
    });

    // Manejar ver compras por cliente
    $('#btnVerCompras').click(function() {
        var idCliente = $('#idCliente').val();
        if (!idCliente) {
            alert('Por favor, seleccione un cliente.');
            return;
        }

        $.ajax({
            url: 'php/reporteComprasPorCliente.php',
            method: 'GET',
            data: { idCliente: idCliente },
            dataType: 'json',
            success: function(data) {
                var resultado = $('#resultadoReporte');
                resultado.empty();

                // Verificar que los datos se recibieron correctamente
                console.log('Datos recibidos:', data);

                if (data && data.compras && data.detalles) {
                    data.compras.forEach(function(compra) {
                        resultado.append(`
                            <div>
                                <strong>ID Compra:</strong> ${compra.id_Compra}<br>
                                <strong>Fecha:</strong> ${compra.fecha}<br>
                                <strong>Total:</strong> $${parseFloat(compra.total).toFixed(2)}
                                <ul id="detalles-${compra.id_Compra}">
                                </ul>
                            </div><hr>
                        `);

                        // Filtrar y mostrar detalles de la compra
                        var detallesList = $(`#detalles-${compra.id_Compra}`);
                        data.detalles.forEach(function(detalle) {
                            if (detalle.id_Factura === compra.id_Compra) {
                                detallesList.append(`
                                    <li>
                                        <strong>Producto:</strong> ${detalle.nombre_Producto}<br>
                                        <strong>Cantidad:</strong> ${detalle.cantidad}<br>
                                        <strong>Precio:</strong> $${parseFloat(detalle.precio).toFixed(2)}
                                    </li>
                                `);
                            }
                        });

                        // Verificar que los detalles se están agregando correctamente
                        console.log(`Detalles para la compra ${compra.id_Compra}:`, detallesList.html());
                    });
                } else {
                    resultado.append('<p>No se encontraron compras para el cliente seleccionado.</p>');
                }
            },
            error: function() {
                alert('Error al cargar las compras.');
            }
        });
    });

    // Función para cargar otros reportes (similar a antes)
    $('#btnCargarReporte').click(function () {
        var reporte = $('#reporte').val();
        if (reporte === 'comprasCliente') return;  // Evitar duplicar la llamada para 'comprasCliente'

        var url = '';

        // Determinar la URL del reporte seleccionado
        switch (reporte) {
            case 'inventario':
                url = 'php/reporteInventario.php';
                break;
            case 'historialVentas':
                url = 'php/reporteHistorialVentasPorTienda.php';
                break;
            case 'productosMasVendidosTienda':
                url = 'php/reporteProductosMasVendidosPorTienda.php';
                break;
            case 'productosMasVendidosPais':
                url = 'php/reporteProductosMasVendidosPorPais.php';
                break;
            case 'tiendasMasVentas':
                url = 'php/reporteTiendasConMasVentas.php';
                break;
            case 'cocaColaVsPepsi':
                url = 'php/reporteTiendasCocaColaVsPepsi.php';
                break;
            case 'productosSinLeche':
                url = 'php/reporteProductosSinLeche.php';
                break;
        }

        // Hacer la petición AJAX para cargar el reporte
        $.ajax({
            url: url,
            method: 'GET',
            dataType: 'json',
            success: function(data) {
                var resultado = '<table><thead><tr>';

                // Crear encabezados de tabla basados en los campos del reporte
                for (var key in data[0]) {
                    resultado += '<th>' + key + '</th>';
                }
                resultado += '</tr></thead><tbody>';

                // Rellenar las filas de la tabla con los datos del reporte
                data.forEach(function(row) {
                    resultado += '<tr>';
                    for (var key in row) {
                        resultado += '<td>' + row[key] + '</td>';
                    }
                    resultado += '</tr>';
                });

                resultado += '</tbody></table>';
                $('#resultadoReporte').html(resultado);
            },
            error: function() {
                alert('Error al cargar el reporte.');
            }
        });
    });






    










            

                // Cargar clientes al inicio para la selección
                $.ajax({
                    url: 'php/cargarClientes.php',
                    method: 'GET',
                    dataType: 'json',
                    success: function(data) {
                        var select = $('#idCliente');
                        select.empty();
                        if (Array.isArray(data)) {
                            data.forEach(function(cliente) {
                                select.append(`<option value="${cliente.id_Cliente}">${cliente.nombre1} ${cliente.nombre2} ${cliente.apellido1} ${cliente.apellido2}</option>`);
                            });
                        } else {
                            select.append('<option>Error al cargar clientes.</option>');
                        }
                    },
                    error: function() {
                        alert('Error al cargar clientes.');
                    }
                });

                // Manejar ver compras por cliente
                $('#btnVerCompras').click(function() {
                    var idCliente = $('#idCliente').val();
                    $.ajax({
                        url: 'php/ObtenerComprasPorCliente.php',
                        method: 'GET',
                        data: { idCliente: idCliente },
                        dataType: 'json',
                        success: function(data) {
                            console.log("Datos recibidos del servidor:", data); // Verifica la estructura de datos aquí
                            var list = $('#comprasList');
                            list.empty();
                
                            if (data && data.compras && data.detalles) {
                                // Mostrar las compras y sus detalles
                                data.compras.forEach(function(compra) {
                                    list.append(`<li><strong>ID Compra:</strong> ${compra.id_Compra}, <strong>Fecha:</strong> ${compra.fecha}, <strong>Total:</strong> ${compra.total}</li>`);
                                    
                                    // Crear una lista anidada para los detalles de cada compra
                                    var detallesList = $('<ul></ul>');
                                    data.detalles.forEach(function(detalle) {
                                        if (detalle.id_Compra === compra.id_Compra) {
                                            detallesList.append(`<li><strong>Producto:</strong> ${detalle.nombre}, <strong>Cantidad:</strong> ${detalle.cantidad}, <strong>Precio:</strong> ${detalle.precio}, <strong>UPC:</strong> ${detalle.UPC_Producto}</li>`);
                                        }
                                    });
                                    list.append(detallesList);
                                });
                
                            } else {
                                list.append('<li>No se encontraron compras para el cliente seleccionado.</li>');
                            }
                        },
                        error: function() {
                            alert('Error al cargar compras.');
                        }
                    });
                });


                
                







    // Cargar tiendas al inicio
    $.ajax({
        url: 'php/cargarTiendas.php', // Verifica que esta ruta sea correcta
        method: 'GET',
        dataType: 'json',
        success: function(data) {
            var tiendaSelect = $('#id_Tienda');
            tiendaSelect.empty();
            tiendaSelect.append('<option value="">Seleccione una tienda</option>');
            if (Array.isArray(data)) {
                data.forEach(function(tienda) {
                    tiendaSelect.append(`<option value="${tienda.id_Tienda}">${tienda.nombre_Tienda}</option>`);
                });
            } else {
                tiendaSelect.append('<option value="">Error al cargar tiendas.</option>');
            }
        },
        error: function() {
            alert('Error al cargar tiendas.');
        }
    });

    // Cargar inventario al seleccionar una tienda
    $('#btnCargarInventario').click(function() {
        const id_Tienda = $('#id_Tienda').val();
        if (id_Tienda === '') {
            alert('Por favor, seleccione una tienda.');
            return;
        }

        $.ajax({
            url: 'php/cargarInventarioPorTienda.php', // Verifica que esta ruta sea correcta
            method: 'GET',
            data: { id_Tienda: id_Tienda },
            dataType: 'json',
            success: function(data) {
                var list = $('#inventarioList');
                list.empty();
                if (Array.isArray(data)) {
                    data.forEach(function(inventario) {
                        list.append(`<li class="list-group-item">UPC Producto: ${inventario.UPC_Producto}, Nombre Producto: ${inventario.nombre_Producto}, Cantidad: ${inventario.cantidad}</li>`);
                    });
                } else {
                    list.append('<li class="list-group-item">Error: Los datos no están en el formato esperado.</li>');
                }
            },
            error: function() {
                alert('Error al cargar inventario.');
            }
        });
    });

    // Función para gestionar inventario
    function gestionarInventario(accion) {
        const id_Tienda = $('#id_Tienda').val();
        const data = {
            accion: accion,
            UPC_Producto: $('#UPC_Producto').val(),
            id_Tienda: id_Tienda,
            cantidad: $('#cantidad').val()
        };

        $.post('php/inventario.php', data, function(response) {
            alert(response);
            $('#inventarioForm')[0].reset(); // Limpiar el formulario
            $('#btnCargarInventario').click(); // Recargar la lista de inventario
        });
    }

    // Agregar inventario
    $('#btnAgregarInventario').click(function() {
        gestionarInventario('create');
    });

    // Modificar inventario
    $('#btnModificarInventario').click(function() {
        gestionarInventario('update');
    });

    // Eliminar inventario
    $('#btnEliminarInventario').click(function() {
        gestionarInventario('delete');
    });


    //FIN
});
