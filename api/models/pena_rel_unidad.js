/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('pena_rel_unidad', {
		fk_pena_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'pena',
				key: 'id_pena'
			}
		},
		fk_unidad_nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			references: {
				model: 'unidad',
				key: 'nombre'
			}
		},
		valor: {
			type: DataTypes.DOUBLE,
			allowNull: false
		}
	}, {
		tableName: 'pena_rel_unidad',
		timestamps: false
	});
};
