/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('categoria_resto_indice', {
		id_categoria_resto_indice: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_categoria_resto_indice::regclass)",
			primaryKey: true
		},
		fk_categoria_resto_indice_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'categoria_resto_indice',
				key: 'id_categoria_resto_indice'
			}
		},
		fk_categoria_resto_nombre: {
			type: DataTypes.STRING,
			allowNull: true,
			references: {
				model: 'categoria_resto',
				key: 'nombre'
			}
		}
	}, {
		tableName: 'categoria_resto_indice',
		timestamps: false
	});
};
