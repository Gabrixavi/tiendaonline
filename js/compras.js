$(document).ready(function() {
    var compra = [];

    // Cargar clientes al iniciar la página
    cargarClientes();

    // Cargar tiendas al iniciar la página
    cargarTiendas();

    // Cargar productos para la compra
    cargarProductosParaCompra();

    // Agregar producto al resumen de la compra
    $('#btnAgregarProducto').click(function () {
        var productoId = $('#producto').val();
        var cantidad = parseInt($('#cantidad').val());
        var productoTexto = $('#producto option:selected').text();
        var precio = parseFloat($('#producto option:selected').data('precio'));

        if (!productoId || cantidad <= 0 || isNaN(precio)) {
            alert('Por favor, seleccione un producto, una cantidad válida y asegúrese de que el precio es correcto.');
            return;
        }

        var total = precio * cantidad;
        compra.push({ productoId: productoId, productoTexto: productoTexto, cantidad: cantidad, precio: precio, total: total });

        actualizarResumenCompra();
    });

    // Función para actualizar el resumen de la compra
    function actualizarResumenCompra() {
        var resumen = $('#compraResumen');
        resumen.empty();

        compra.forEach(function(item, index) {
            resumen.append(`
                <tr>
                    <td>${item.productoTexto}</td>
                    <td>${item.cantidad}</td>
                    <td>${item.precio.toFixed(2)}</td>
                    <td>${item.total.toFixed(2)}</td>
                    <td><button type="button" class="btn btn-danger" onclick="eliminarProducto(${index})">Eliminar</button></td>
                </tr>
           `);
        });
    }

    // Función para eliminar un producto del resumen de la compra
    function eliminarProducto(index) {
        compra.splice(index, 1);
        actualizarResumenCompra();
    }

    // Confirmar compra
    $('#btnConfirmarCompra').click(function () {
        var clienteId = $('#cliente').val();
        var tiendaId = $('#tienda').val();

        if (!clienteId || !tiendaId || compra.length === 0) {
            alert('Por favor, complete todos los campos y agregue al menos un producto.');
            return;
        }

        $.ajax({
            url: 'php/confirmarCompra.php',
            method: 'POST',
            data: {
                clienteId: clienteId,
                tiendaId: tiendaId,
                productos: compra
            },
            success: function(response) {
                alert(response);
                location.reload();  // Recargar la página para limpiar el formulario
            },
            error: function() {
                alert('Error al confirmar la compra.');
            }
        });
    });

    // Funciones para cargar clientes, tiendas y productos
    function cargarClientes() {
        $.ajax({
            url: 'php/cargarClientes.php',
            method: 'GET',
            dataType: 'json',
            success: function(data) {
                var clienteSelect = $('#cliente');
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
    }

    function cargarTiendas() {
        $.ajax({
            url: 'php/cargarTiendas.php',
            method: 'GET',
            dataType: 'json',
            success: function(data) {
                var tiendaSelect = $('#tienda');
                tiendaSelect.empty();
                tiendaSelect.append('<option value="">Seleccione una tienda</option>');
                data.forEach(function(tienda) {
                    tiendaSelect.append(`<option value="${tienda.id_Tienda}">${tienda.nombre_Tienda}</option>`);
                });
            },
            error: function() {
                alert('Error al cargar las tiendas.');
            }
        });
    }

    function cargarProductosParaCompra() {
        $.ajax({
            url: 'php/cargarProductosSelect.php',
            method: 'GET',
            dataType: 'json',
            success: function(data) {
                var productoSelect = $('#producto');
                productoSelect.empty();
                productoSelect.append('<option value="">Seleccione un producto</option>');
                data.forEach(function(producto) {
                    productoSelect.append(`<option value="${producto.UPC}" data-precio="${producto.precio}">${producto.nombre}</option>`);
                });
            },
            error: function() {
                alert('Error al cargar los productos.');
            }
        });
    }
});
