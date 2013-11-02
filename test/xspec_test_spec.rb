require 'rspec'

class Object
  def deberia(comparador)
    raise('fallo la comparación') unless comparador.comparar_con(self)
  end

  def ser(comparador)
    comparador
  end

  def igual_a(objeto)
    IgualA.new(objeto)
  end

  def mayor_a(objeto)
    MayorA.new(objeto)
  end

end


class ComparadorBinario
  def initialize(derecha)
    @derecha=derecha
  end
end

class IgualA < ComparadorBinario
  def comparar_con(izquierda)
    izquierda==@derecha
  end
end

class MayorA < ComparadorBinario
  def comparar_con(izquierda)
    izquierda>@derecha
  end
end

class Object
  def especificacion(&bloque_configuracion)
    especificacion=Especificacion.new
    especificacion.instance_eval &bloque_configuracion
    especificacion.evaluar
  end

  def validar(&bloque_configuracion)
    especificacion_mapa=EspecificacionMapa.new
    especificacion_mapa.instance_eval &bloque_configuracion
    especificacion_mapa.evaluar
  end
end

class Especificacion
  def esperando(&condicion)
    @condicion = condicion
  end

  def siendo(valores)
    @valores = valores
  end

  def evaluar
    @valores.each { |valor|
      valor.instance_eval &@condicion
    }
  end
end

class EspecificacionMapa < Especificacion
  def evaluar
    @valores.each { |mapa_valores|
      self.evaluar_mapa mapa_valores
    }
  end

  def evaluar_mapa(mapa_valores)
    objeto = self.crear_objeto(mapa_valores)
    objeto.instance_eval &@condicion
  end

  def crear_objeto(mapa)
    ObjetoMapa.new(mapa)
  end
end

class ObjetoMapa
  def initialize(mapa)
    @mapa = mapa
  end

  def method_missing(name, *args, &block)
    if not @mapa.key? name
      super
    else
      @mapa[name]
    end
  end
end

describe 'probar xspec' do

  it 'testear esperando con un mapa' do
    expect { validar do
      esperando do
        (x+y).deberia ser mayor_a z
      end
      siendo [{u: 5, y: 3, z: 4},
              {x: 6, y: 5, z: 3}]
    end }.to raise_error(NameError)
  end

  it 'testear esperando con un mapa' do
    validar do
      esperando do
        (x+y).deberia ser mayor_a z
      end
      siendo [{x: 5, y: 3, z: 4},
              {x: 6, y: 5, z: 3}]
    end
  end

  it 'testear esperando con un mapa' do
    expect {
      validar do
        esperando do
          (x+y).deberia ser mayor_a z
        end
        siendo [{x: 1, y: 2, z: 4},
                {x: 6, y: 5, z: 3}]
      end }.to raise_error(Exception)
  end

  it 'test especificacion' do
    especificacion do
      esperando do
        deberia ser mayor_a 5
      end
      siendo [6, 7, 8, 42]
    end
  end

  it 'test especificacion' do
    expect { especificacion do
      esperando do
        deberia ser mayor_a 4
      end
      siendo [1, 3, 9]
    end }.to raise_error(Exception)
  end

  it 'should hacer algo' do
    (5+2).deberia ser igual_a 7
  end

  it 'probar comparador mayor a' do
    (6+4).deberia ser mayor_a 5
  end

  it 'test que deberia fallar' do
    expect { (5+2).deberia ser igual_a 92 }.to raise_error(Exception)
  end

end