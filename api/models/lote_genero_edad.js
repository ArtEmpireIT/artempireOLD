/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('lote_genero_edad', {
		fk_lote_id: {
			type: DataTypes.INTEGER,
			allowNull: false,
			primaryKey: true,
			references: {
				model: 'lote',
				key: 'id_lote'
			}
		},
		fk_genero_lote_nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			references: {
				model: 'genero_lote',
				key: 'nombre'
			}
		},
		fk_edad_lote_nombre: {
			type: DataTypes.STRING,
			allowNull: false,
			references: {
				model: 'edad_lote',
				key: 'nombre'
			}
		},
		cantidad: {
			type: DataTypes.INTEGER,
			allowNull: true
		}
	}, {
		tableName: 'lote_genero_edad',
		timestamps: false
	});
};
