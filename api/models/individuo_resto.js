/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('individuo_resto', {
    id_individuo_resto: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 'nextval(id_individuo_resto::regclass)',
      primaryKey: true
    },
    pos_extremidades_inf: {
      type: DataTypes.STRING,
      allowNull: true
    },
    pos_extremidades_sup: {
      type: DataTypes.STRING,
      allowNull: true
    },
    posicion_cuerpo: {
      type: DataTypes.STRING,
      allowNull: true
    },
    orientacion_cuerpo: {
      type: DataTypes.STRING,
      allowNull: true
    },
    orientacion_craneo: {
      type: DataTypes.STRING,
      allowNull: true
    },
    fk_resto_variable: {
      type: DataTypes.STRING,
      allowNull: true,
      references: {
        model: 'resto',
        key: 'variable'
      }
    },
    fk_especie_nombre: {
      type: DataTypes.STRING,
      allowNull: true,
      references: {
        model: 'especie',
        key: 'nombre'
      }
    },
    fk_individuo_arqueologico_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'individuo_arqueologico',
        key: 'id_individuo_arqueologico'
      }
    }
  }, {
    tableName: 'individuo_resto',
    timestamps: false
  });
};
