/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('rel_iti_obj_trans', {
		id_rel_iti_obj_trans: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_rel_iti_obj_trans::regclass)",
			primaryKey: true
		},
		fk_paso_itinerario_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'paso_itinerario',
				key: 'id_paso_itinerario'
			}
		},
		fk_transporte_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'transporte',
				key: 'id_transporte'
			}
		},
		fk_agrupacion_bienes_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'agrupacion_bienes',
				key: 'id_agrupacion_bienes'
			}
		}
	}, {
		tableName: 'rel_iti_obj_trans',
		timestamps: false
	});
};
